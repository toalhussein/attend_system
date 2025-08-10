import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

class PDFGenerationDialog extends StatelessWidget {
  final ValueNotifier<String>? progressNotifier;

  const PDFGenerationDialog({
    Key? key,
    this.progressNotifier,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1976D2),
                  strokeWidth: 3,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Generating PDF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2C2C2C),
              ),
            ),
            const SizedBox(height: 8),
            if (progressNotifier != null)
              ValueListenableBuilder<String>(
                valueListenable: progressNotifier!,
                builder: (context, message, child) {
                  return Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  );
                },
              )
            else
              Text(
                'Please wait...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }
}

class PDFService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static Future<void> generateAttendanceReport(
    BuildContext context, {
    ValueNotifier<String>? progressNotifier,
  }) async {
    // Use provided notifier or create a new one
    final ValueNotifier<String> notifier = progressNotifier ?? ValueNotifier<String>('Initializing...');
    
    // Only show dialog if no external progress notifier is provided
    if (progressNotifier == null) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return PDFGenerationDialog(progressNotifier: notifier);
        },
      );
    }

    try {
      // Get current date
      final DateTime now = DateTime.now();
      final String currentDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      dev.log('Current date: $currentDate');
      
      // Update progress
      notifier.value = 'Fetching attendance data...';
      
      // Fetch attendance records for current date
      final List<Map<String, dynamic>> attendanceData = await _fetchAttendanceData(currentDate);
      dev.log('Fetched ${attendanceData.length} attendance records');

      if (attendanceData.isEmpty) {
        dev.log('No attendance data found');
        // Only close dialog if we created it (not provided externally)
        if (progressNotifier == null && context.mounted) {
          Navigator.of(context).pop(); // Close loading dialog
        }
        _showResultDialog(context, false, 'No attendance records found for today', null);
        return;
      }

      // Update progress
      // Generate PDF content
      notifier.value = 'Generating PDF document...';
      dev.log('Starting PDF generation...');

      // Generate PDF using simplified approach
      final pdf = pw.Document();
      
      // Add page with attendance data
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => _buildAttendanceReport(currentDate, attendanceData),
        ),
      );
      dev.log('PDF content added successfully');
      
      // Update progress
      notifier.value = 'Saving PDF to device...';
      dev.log('Starting PDF save process...');
      
      // Wait 2 seconds before proceeding
      await Future.delayed(const Duration(seconds: 2));
      
      // Close progress dialog before opening directory picker (only if we created it)
      if (progressNotifier == null && context.mounted) {
        Navigator.of(context).pop(); // Close the progress dialog
        await Future.delayed(const Duration(milliseconds: 300)); // Allow dialog to close
      } else {
        // For external progress notifiers, signal completion
        notifier.value = 'Opening file picker...';
        await Future.delayed(const Duration(milliseconds: 300)); // Brief pause
      }
      
      // Let user choose save location (no progress dialog open)
      String? filePath = await _savePDFWithUserChoice(context, pdf, currentDate);
      
      if (filePath == null) {
        // User cancelled the save dialog
        if (context.mounted) {
          await Future.delayed(const Duration(milliseconds: 100));
          if (context.mounted) {
            _showResultDialog(context, false, 'Save operation cancelled by user', null);
          }
        }
        return;
      }
      
      dev.log('PDF saved successfully to: $filePath');

      // Show success actions (progress dialog already closed)
      if (context.mounted) {
        dev.log('Showing success dialog and opening file location');
        
        // Small delay to ensure directory picker is closed
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Automatically open the file location
        await _openFileLocation(filePath);
        
        // Show success dialog with file actions
        if (context.mounted) {
          _showResultDialog(context, true, 'PDF report generated and saved successfully!', filePath);
        }
      }

    } catch (e) {
      dev.log('Error generating PDF: ${e.toString()}');
      
      // Show error (progress dialog already closed)
      if (context.mounted) {        
        // Small delay before showing error dialog
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Show error dialog
        if (context.mounted) {
          _showResultDialog(context, false, 'Error generating PDF: $e', null);
        }
      }
    } finally {
      // Only dispose if we created the notifier (not provided externally)
      if (progressNotifier == null) {
        try {
          notifier.dispose();
        } catch (e) {
          dev.log('Error disposing progress notifier: $e');
        }
      }
    }
  }

  // Remove the old _updateProgress method as it's no longer needed

  static void _showResultDialog(BuildContext context, bool success, String message, String? filePath) {
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  success ? 'PDF Saved Successfully!' : 'Save Failed',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: success ? Colors.green : Colors.red,
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: const TextStyle(fontSize: 16),
              ),
              if (success && filePath != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.folder_open,
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'File saved as:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        filePath.split('/').last,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Action buttons for file operations
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _shareFile(filePath),
                        icon: const Icon(Icons.share, size: 18),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.blue,
                          side: const BorderSide(color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openFile(filePath),
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('Open'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (dialogContext.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(
                'Close',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        Fluttertoast.showToast(
          msg: 'Could not open file: ${result.message}',
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error opening file: $e',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  static Future<void> _shareFile(String filePath) async {
    try {
      final XFile xFile = XFile(filePath);
      await Share.shareXFiles([xFile], text: 'Attendance Report PDF');
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error sharing file: $e',
        toastLength: Toast.LENGTH_SHORT,
      );
    }
  }

  static Future<void> _openFileLocation(String filePath) async {
    try {
      dev.log('Attempting to open file location: $filePath');
      
      // First try to open the file directly
      final result = await OpenFile.open(filePath);
      
      if (result.type == ResultType.done) {
        dev.log('File opened successfully');
        Fluttertoast.showToast(
          msg: 'PDF opened successfully!',
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        dev.log('Could not open file directly: ${result.message}');
        
        // If direct opening fails, try to open the directory
        final directory = Directory(filePath).parent;
        final directoryResult = await OpenFile.open(directory.path);
        
        if (directoryResult.type == ResultType.done) {
          dev.log('Directory opened successfully');
          Fluttertoast.showToast(
            msg: 'File location opened successfully!',
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.blue,
            textColor: Colors.white,
          );
        } else {
          dev.log('Could not open directory: ${directoryResult.message}');
          Fluttertoast.showToast(
            msg: 'PDF saved but could not open location',
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: Colors.orange,
            textColor: Colors.white,
          );
        }
      }
    } catch (e) {
      dev.log('Error opening file location: $e');
      Fluttertoast.showToast(
        msg: 'PDF saved successfully',
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    }
  }

  static Future<List<Map<String, dynamic>>> _fetchAttendanceData(String date) async {
    List<Map<String, dynamic>> attendanceData = [];

    try {
      // Get all users
      final usersSnapshot = await _firestore.collection('users').get();

      for (var userDoc in usersSnapshot.docs) {
        final userData = userDoc.data();
        final String userId = userDoc.id;
        final String userName = userData['name'] ?? 'Unknown';
        final String workId = userData['work_id'] ?? 'N/A';
        final String role = userData['role'] ?? 'employee';

        // Get attendance record for the specific date
        try {
          final recordDoc = await _firestore
              .collection('users')
              .doc(userId)
              .collection('records')
              .doc(date)
              .get();

          String checkIn = 'No Check-in';
          String checkOut = 'No Check-out';

          if (recordDoc.exists) {
            final recordData = recordDoc.data()!;
            
            // Format check-in time
            if (recordData['attendance'] != null && recordData['attendance'] != '') {
              final Timestamp attendanceTimestamp = recordData['attendance'];
              final DateTime attendanceTime = attendanceTimestamp.toDate();
              checkIn = _formatTime(attendanceTime);
            }

            // Format check-out time
            if (recordData['departure'] != null && recordData['departure'] != '') {
              final Timestamp departureTimestamp = recordData['departure'];
              final DateTime departureTime = departureTimestamp.toDate();
              checkOut = _formatTime(departureTime);
            }
          }

          attendanceData.add({
            'userId': userId,
            'userName': userName,
            'workId': workId,
            'role': role,
            'checkIn': checkIn,
            'checkOut': checkOut,
          });
        } catch (e) {
          // If no record found for this user on this date, add with no attendance
          attendanceData.add({
            'userId': userId,
            'userName': userName,
            'workId': workId,
            'role': role,
            'checkIn': 'No Check-in',
            'checkOut': 'No Check-out',
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to fetch attendance data: $e');
    }

    return attendanceData;
  }

  static String _formatTime(DateTime dateTime) {
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    String second = dateTime.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }

  static pw.Widget _buildAttendanceReport(String date, List<Map<String, dynamic>> attendanceData) {
    // Sort data by role (admin first, then employees)
    attendanceData.sort((a, b) {
      if (a['role'] == 'admin' && b['role'] != 'admin') return -1;
      if (a['role'] != 'admin' && b['role'] == 'admin') return 1;
      return a['userName'].compareTo(b['userName']);
    });

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Title
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(20),
          decoration: pw.BoxDecoration(
            color: PdfColors.blue800,
            borderRadius: pw.BorderRadius.circular(10),
          ),
          child: pw.Column(
            children: [
              pw.Text(
                'DAILY ATTENDANCE REPORT',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'Date: $date',
                style: pw.TextStyle(
                  fontSize: 16,
                  color: PdfColors.white,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 20),

        // Summary Box
        pw.Container(
          padding: const pw.EdgeInsets.all(15),
          decoration: pw.BoxDecoration(
            color: PdfColors.grey100,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
            children: [
              pw.Column(
                children: [
                  pw.Text('Total Users', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('${attendanceData.length}'),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text('Present', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('${attendanceData.where((user) => user['checkIn'] != 'No Check-in').length}'),
                ],
              ),
              pw.Column(
                children: [
                  pw.Text('Absent', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.Text('${attendanceData.where((user) => user['checkIn'] == 'No Check-in').length}'),
                ],
              ),
            ],
          ),
        ),

        pw.SizedBox(height: 20),

        // Attendance Table
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
          columnWidths: {
            0: const pw.FixedColumnWidth(60),
            1: const pw.FlexColumnWidth(2),
            2: const pw.FlexColumnWidth(1.5),
            3: const pw.FlexColumnWidth(1),
            4: const pw.FlexColumnWidth(1.5),
            5: const pw.FlexColumnWidth(1.5),
          },
          children: [
            // Header row
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.blue800),
              children: [
                _buildTableHeader('S.No'),
                _buildTableHeader('Name'),
                _buildTableHeader('Work ID'),
                _buildTableHeader('Role'),
                _buildTableHeader('Check In'),
                _buildTableHeader('Check Out'),
              ],
            ),
            // Data rows
            ...attendanceData.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> user = entry.value;
              
              return pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: index % 2 == 0 ? PdfColors.grey50 : PdfColors.white,
                ),
                children: [
                  _buildTableCell('${index + 1}'),
                  _buildTableCell(user['userName']),
                  _buildTableCell(user['workId']),
                  _buildTableCell(user['role'].toUpperCase()),
                  _buildTableCell(
                    user['checkIn'],
                    color: user['checkIn'] == 'No Check-in' ? PdfColors.red : PdfColors.green,
                  ),
                  _buildTableCell(
                    user['checkOut'],
                    color: user['checkOut'] == 'No Check-out' ? PdfColors.orange : PdfColors.blue,
                  ),
                ],
              );
            }).toList(),
          ],
        ),

        pw.SizedBox(height: 30),

        // Footer
        pw.Center(
          child: pw.Text(
            'Generated on ${DateTime.now().toString().split('.')[0]}',
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

 static pw.Widget _buildTableCell(String text, {PdfColor? color}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          color: color ?? PdfColors.black,
          fontWeight: color != null ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
    static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
          fontSize: 12,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }
  static Future<String?> _savePDFWithUserChoice(BuildContext context, pw.Document pdf, String date) async {
    try {
      dev.log('Starting user-selected PDF save process');
      final Uint8List bytes = await pdf.save();
      dev.log('PDF bytes generated, size: ${bytes.length}');
      
      final String fileName = 'attendance_report_$date.pdf';
      
      // Show directory picker dialog to user
      String? selectedDirectory;
      try {
        selectedDirectory = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Select folder to save PDF report',
        );
      } catch (e) {
        dev.log('FilePicker error: $e');
        // If FilePicker fails, fall back to default location with user notification
        Fluttertoast.showToast(
          msg: 'Directory picker not available. Using default location.',
          toastLength: Toast.LENGTH_LONG,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
        );
        return await _savePDFDefault(pdf, date);
      }
      
      if (selectedDirectory == null) {
        // User cancelled the directory selection
        dev.log('User cancelled directory selection');
        return null;
      }
      
      // Save to selected directory
      final String filePath = '$selectedDirectory/$fileName';
      dev.log('Target file path: $filePath');

      // Create file and write bytes
      final File file = File(filePath);
      await file.writeAsBytes(bytes);
      dev.log('File written successfully');

      // Verify file exists and has content
      final bool fileExists = await file.exists();
      final int fileSize = await file.length();
      dev.log('File verification - exists: $fileExists, size: $fileSize');

      if (!fileExists) {
        throw Exception('File was not created');
      }
      
      if (fileSize == 0) {
        throw Exception('File was created but is empty');
      }

      return filePath;
    } catch (e) {
      dev.log('Error in _savePDFWithUserChoice: ${e.toString()}');
      // If there's an error, fall back to default save method
      Fluttertoast.showToast(
        msg: 'Error with selected location. Using default location.',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return await _savePDFDefault(pdf, date);
    }
  }
  static Future<String> _savePDFDefault(pw.Document pdf, String date) async {
    try {
      dev.log('Starting reliable PDF save process');
      final Uint8List bytes = await pdf.save();
      dev.log('PDF bytes generated, size: ${bytes.length}');
      
      String filePath;
      final String fileName = 'attendance_report_$date.pdf';
      
      try {
        // Method 1: Try to save to Downloads directory (if available)
        final Directory? downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          filePath = '${downloadsDir.path}/$fileName';
          dev.log('Using Downloads directory: ${downloadsDir.path}');
        } else {
          throw Exception('Downloads directory not available');
        }
      } catch (e) {
        dev.log('Downloads directory failed: $e, trying external storage');
        try {
          // Method 2: Try external storage directory
          final Directory? externalDir = await getExternalStorageDirectory();
          if (externalDir != null) {
            filePath = '${externalDir.path}/$fileName';
            dev.log('Using external storage directory: ${externalDir.path}');
          } else {
            throw Exception('External storage directory not available');
          }
        } catch (e2) {
          dev.log('External storage failed: $e2, using documents directory');
          // Method 3: Fallback to app documents directory (always available)
          final Directory documentsDir = await getApplicationDocumentsDirectory();
          filePath = '${documentsDir.path}/$fileName';
          dev.log('Using documents directory: ${documentsDir.path}');
        }
      }
      
      dev.log('Target file path: $filePath');

      // Create directory if it doesn't exist and write file
      final File file = File(filePath);
      await file.parent.create(recursive: true);
      dev.log('Directory created/verified');

      await file.writeAsBytes(bytes);
      dev.log('File written successfully');

      // Verify file exists and has content
      final bool fileExists = await file.exists();
      final int fileSize = await file.length();
      dev.log('File verification - exists: $fileExists, size: $fileSize');

      if (!fileExists) {
        throw Exception('File was not created');
      }
      
      if (fileSize == 0) {
        throw Exception('File was created but is empty');
      }

      return filePath;
    } catch (e) {
      dev.log('Error in _savePDFDefault: ${e.toString()}');
      rethrow;
    }
  }
}

  // Old complex method - replaced with simpler _buildAttendanceReport
  /*
  static Future<void> _addPDFContent(
    pw.Document pdf,
    String date,
    List<Map<String, dynamic>> attendanceData,
  ) async {
    dev.log('Starting _addPDFContent with ${attendanceData.length} records');
    
    // Sort data by role (admin first, then employees)
    attendanceData.sort((a, b) {
      if (a['role'] == 'admin' && b['role'] != 'admin') return -1;
      if (a['role'] != 'admin' && b['role'] == 'admin') return 1;
      return a['userName'].compareTo(b['userName']);
    });
    
    dev.log('Data sorted successfully');

    try {
      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          build: (pw.Context context) {
            dev.log('Building PDF page content');
            return [
              // Header
              pw.Container(
                padding: const pw.EdgeInsets.all(20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue800,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      'ATTENDANCE REPORT',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 8),
                    pw.Text(
                      'Date: $date',
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.white,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Generated on: ${DateTime.now().toString().substring(0, 19)}',
                      style: pw.TextStyle(
                        fontSize: 12,
                        color: PdfColors.white,
                      ),
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Summary
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    pw.Column(
                      children: [
                        pw.Text(
                          'Total Users',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text('${attendanceData.length}'),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text(
                          'Present',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text('${attendanceData.where((user) => user['checkIn'] != 'No Check-in').length}'),
                      ],
                    ),
                    pw.Column(
                      children: [
                        pw.Text(
                          'Absent',
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),
                        pw.Text('${attendanceData.where((user) => user['checkIn'] == 'No Check-in').length}'),
                      ],
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 20),

              // Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400, width: 1),
                columnWidths: {
                  0: const pw.FixedColumnWidth(60),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1),
                  4: const pw.FlexColumnWidth(1.5),
                  5: const pw.FlexColumnWidth(1.5),
                },
                children: [
                  // Header row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.blue800),
                    children: [
                      _buildTableHeader('S.No'),
                      _buildTableHeader('Name'),
                      _buildTableHeader('Work ID'),
                      _buildTableHeader('Role'),
                      _buildTableHeader('Check In'),
                      _buildTableHeader('Check Out'),
                    ],
                  ),
                  // Data rows
                  ...attendanceData.asMap().entries.map((entry) {
                    int index = entry.key;
                    Map<String, dynamic> user = entry.value;
                    
                    return pw.TableRow(
                      decoration: pw.BoxDecoration(
                        color: index % 2 == 0 ? PdfColors.grey50 : PdfColors.white,
                      ),
                      children: [
                        _buildTableCell('${index + 1}'),
                        _buildTableCell(user['userName']),
                        _buildTableCell(user['workId']),
                        _buildTableCell(user['role'].toUpperCase()),
                        _buildTableCell(
                          user['checkIn'],
                          color: user['checkIn'] == 'No Check-in' ? PdfColors.red : PdfColors.green,
                        ),
                        _buildTableCell(
                          user['checkOut'],
                          color: user['checkOut'] == 'No Check-out' ? PdfColors.orange : PdfColors.blue,
                        ),
                      ],
                    );
                  }),
                ],
              ),

              pw.SizedBox(height: 30),

              // Footer
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'This is a computer-generated report.',
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            ];
          },
        ),
      );
      
      dev.log('PDF page added successfully');
    } catch (e) {
      dev.log('Error in _addPDFContent: ${e.toString()}');
      throw Exception('Failed to create PDF content: $e');
    }
  }

  static pw.Widget _buildTableHeader(String text) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
          fontSize: 12,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  static pw.Widget _buildTableCell(String text, {PdfColor? color}) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          color: color ?? PdfColors.black,
          fontWeight: color != null ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
        textAlign: pw.TextAlign.center,
      ),
    );
  }

  

  
}
*/
