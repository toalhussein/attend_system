import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ExcelService {
  static Future<void> generateAttendanceReport(
    BuildContext context, {
    required ValueNotifier<String> progressNotifier,
  }) async {
    try {
      progressNotifier.value = 'Preparing Excel report...';

      // Get current date
      final now = DateTime.now();
      final currentDate = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      progressNotifier.value = 'Fetching user data...';

      // Fetch all users from Firestore
      final usersSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .orderBy('work_id')
          .get();

      if (usersSnapshot.docs.isEmpty) {
        progressNotifier.value = 'No users found';
        return;
      }

      progressNotifier.value = 'Fetching attendance records...';

      // Create Excel workbook
      final excel = Excel.createExcel();
      final sheet = excel['Attendance Report'];
      excel.delete('Sheet1'); // Remove default sheet

      // Set column widths
      sheet.setColumnWidth(0, 15.0); // Work ID
      sheet.setColumnWidth(1, 25.0); // User Name
      sheet.setColumnWidth(2, 20.0); // Check In
      sheet.setColumnWidth(3, 20.0); // Check Out
      sheet.setColumnWidth(4, 15.0); // Status

      // Create header style
      final headerStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#4285F4'),
        fontColorHex: ExcelColor.white,
        bold: true,
      );

      // Create data style
      final dataStyle = CellStyle(
        bold: false,
      );

      // Create alternating row style
      final altRowStyle = CellStyle(
        backgroundColorHex: ExcelColor.fromHexString('#F8F9FA'),
      );

      // Add title
      final titleCell = sheet.cell(CellIndex.indexByString('A1'));
      titleCell.value = TextCellValue('Daily Attendance Report - $currentDate');
      titleCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 16,
      );

      // Merge title cells
      sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('E1'));

      // Add headers
      final headers = ['Work ID', 'User Name', 'Check In', 'Check Out', 'Status'];
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 2));
        cell.value = TextCellValue(headers[i]);
        cell.cellStyle = headerStyle;
      }

      int rowIndex = 3;
      int processedUsers = 0;

      for (final userDoc in usersSnapshot.docs) {
        progressNotifier.value = 'Processing user ${processedUsers + 1}/${usersSnapshot.docs.length}...';

        final userData = userDoc.data();
        final String userId = userDoc.id;
        final String workId = userData['work_id'] ?? 'N/A';
        final String userName = userData['name'] ?? 'Unknown';

        String checkIn = 'No Check-in';
        String checkOut = 'No Check-out';
        String status = 'Absent';

        try {
          // Fetch today's attendance record from user's records subcollection
          final recordDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .collection('records')
              .doc(currentDate)
              .get();

          if (recordDoc.exists) {
            final recordData = recordDoc.data()!;
            
            // Format check-in time (attendance field)
            if (recordData['attendance'] != null) {
              final Timestamp attendanceTimestamp = recordData['attendance'];
              final DateTime attendanceTime = attendanceTimestamp.toDate();
              checkIn = _formatTime(attendanceTime);
              status = 'Present';
            }
            
            // Format check-out time (departure field)
            if (recordData['departure'] != null) {
              final Timestamp departureTimestamp = recordData['departure'];
              final DateTime departureTime = departureTimestamp.toDate();
              checkOut = _formatTime(departureTime);
              status = 'Completed';
            }
          }
        } catch (e) {
          dev.log('Error fetching attendance for user $userId: ${e.toString()}');
        }

        // Determine row style (alternating colors)
        final currentRowStyle = (rowIndex - 3) % 2 == 0 ? dataStyle : altRowStyle;

        // Add data to row
        final rowData = [workId, userName, checkIn, checkOut, status];
        for (int i = 0; i < rowData.length; i++) {
          final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: rowIndex));
          cell.value = TextCellValue(rowData[i]);
          cell.cellStyle = currentRowStyle;
        }

        rowIndex++;
        processedUsers++;
      }

      // Add summary section
      rowIndex += 2; // Add some space
      
      final summaryCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
      summaryCell.value = TextCellValue('Summary');
      summaryCell.cellStyle = CellStyle(
        bold: true,
        fontSize: 14,
      );

      rowIndex++;
      
      final totalUsersCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
      totalUsersCell.value = TextCellValue('Total Users: ${usersSnapshot.docs.length}');
      totalUsersCell.cellStyle = dataStyle;

      rowIndex++;
      
      final reportDateCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
      reportDateCell.value = TextCellValue('Report Date: $currentDate');
      reportDateCell.cellStyle = dataStyle;

      rowIndex++;
      
      final generatedAtCell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: rowIndex));
      generatedAtCell.value = TextCellValue('Generated At: ${_formatDateTime(DateTime.now())}');
      generatedAtCell.cellStyle = dataStyle;

      progressNotifier.value = 'Saving Excel file...';

      // Save Excel file with user-selected location
      final fileBytes = excel.save();
      if (fileBytes != null) {
        final fileName = 'attendance_report_$currentDate.xlsx';
        final Uint8List uint8bytes = Uint8List.fromList(fileBytes);
        
        // Let user choose save location
        String? filePath = await _saveExcelWithUserChoice(context, uint8bytes, fileName);
        
        if (filePath == null) {
          // User cancelled - don't show error, just return quietly
          progressNotifier.value = 'Save operation cancelled';
          return;
        }
        
        dev.log('Excel saved successfully to: $filePath');

        // Automatically open the file location
        await _openExcelFileLocation(filePath);

        progressNotifier.value = 'Excel report saved successfully!';
        
        // Show enhanced snackbar with actions
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Excel saved: ${filePath.split('/').last}'),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                label: 'Open',
                textColor: Colors.white,
                onPressed: () async {
                  try {
                    await OpenFile.open(filePath);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Could not open file: $e'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ),
          );
        }
      } else {
        throw Exception('Failed to generate Excel file');
      }

    } catch (e) {
      progressNotifier.value = 'Error: ${e.toString()}';
      dev.log('Error generating Excel report: ${e.toString()}');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate Excel report: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  static Future<String?> _saveExcelWithUserChoice(BuildContext context, Uint8List bytes, String fileName) async {
    try {
      dev.log('Starting user-selected Excel save process');
      dev.log('Excel bytes size: ${bytes.length}');
      
      // Show directory picker dialog to user
      String? selectedDirectory;
      try {
        selectedDirectory = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Select folder to save Excel report',
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
        return await _saveExcelDefault(bytes, fileName);
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
      dev.log('Error in _saveExcelWithUserChoice: ${e.toString()}');
      // If there's an error, fall back to default save method
      Fluttertoast.showToast(
        msg: 'Error with selected location. Using default location.',
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: Colors.orange,
        textColor: Colors.white,
      );
      return await _saveExcelDefault(bytes, fileName);
    }
  }

  static Future<String> _saveExcelDefault(Uint8List bytes, String fileName) async {
    try {
      dev.log('Starting reliable Excel save process');
      dev.log('Excel bytes size: ${bytes.length}');
      
      String filePath;
      
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
      dev.log('Error in _saveExcelDefault: ${e.toString()}');
      rethrow;
    }
  }

  static Future<void> _openExcelFileLocation(String filePath) async {
    try {
      dev.log('Attempting to open Excel file location: $filePath');
      
      // First try to open the file directly
      final result = await OpenFile.open(filePath);
      
      if (result.type == ResultType.done) {
        dev.log('Excel file opened successfully');
        // Don't show toast here as snackbar will handle success message
      } else {
        dev.log('Could not open Excel file directly: ${result.message}');
        
        // If direct opening fails, try to open the directory
        final directory = Directory(filePath).parent;
        final directoryResult = await OpenFile.open(directory.path);
        
        if (directoryResult.type == ResultType.done) {
          dev.log('Excel file directory opened successfully');
        } else {
          dev.log('Could not open Excel directory: ${directoryResult.message}');
        }
      }
    } catch (e) {
      dev.log('Error opening Excel file location: $e');
      // Don't show error toast as the file was still saved successfully
    }
  }

  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }

  static String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${_formatTime(dateTime)}';
  }
}
