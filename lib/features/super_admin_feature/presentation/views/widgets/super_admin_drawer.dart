import 'package:attend_system/core/widgets/custom_logout_icon.dart';
import 'package:attend_system/features/super_admin_feature/presentation/views/widgets/delete_user.dart';
import 'package:attend_system/core/services/pdf_service.dart';
import 'package:attend_system/core/services/excel_service.dart';
import 'package:flutter/material.dart';
import 'create_user.dart';

class SuperAdminDrawer extends StatelessWidget {
  const SuperAdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          Container(
            height: 120,
            color: const Color(0xFF1976D2),
            child: const Center(
              child: Text(
                'Super Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildMenuTile(
            context,
            title: 'Create User',
            icon: Icons.person_add_rounded,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateUserPage(),
                ),
              );
            },
          ),
          _buildMenuTile(
            context,
            title: 'Delete User',
            icon: Icons.person_remove_rounded,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DeleteUserPage(),
                ),
              );
            },
          ),
          _buildMenuTile(
            context,
            title: 'Analysis Sheet',
            icon: Icons.analytics_rounded,
            onTap: () async {
              Navigator.pop(context);
              // Show export options dialog
              _showExportDialog(context);
            },
          ),
          // _buildMenuTile(
          //   context,
          //   title: 'User Details',
          //   icon: Icons.person_search_rounded,
          //   onTap: () async {
          //     Navigator.pop(context);
          //     await Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const UserDetailsPage(
          //           name: 'name',
          //           workId: 'work_id',
          //           role: 'role',
          //           residenceCity: 'residence_city',
          //           workCity: 'work_city',
          //         ),
          //       ),
          //     );
          //   },
          // ),
          const SizedBox(height: 24),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 1,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const CustomLogoutButton(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                // Header Icon
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.file_download,
                    color: Color(0xFF1976D2),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                const Text(
                  'Export Analysis',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Description
                Text(
                  'Choose the format to export attendance data:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  children: [
                    // PDF Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _exportAsPDF(context);
                        },
                        icon: const Icon(Icons.picture_as_pdf, size: 20),
                        label: const Text(
                          'PDF',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    
                    // Excel Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _exportAsExcel(context);
                        },
                        icon: const Icon(Icons.table_chart, size: 20),
                        label: const Text(
                          'Excel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Cancel Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _exportAsPDF(BuildContext context) async {
    // Show progress dialog
    final ValueNotifier<String> progressNotifier = ValueNotifier<String>('Preparing PDF...');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                    color: const Color(0xFFD32F2F).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFD32F2F),
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
                ValueListenableBuilder<String>(
                  valueListenable: progressNotifier,
                  builder: (context, status, child) {
                    return Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      await PDFService.generateAttendanceReport(context, progressNotifier: progressNotifier);
      
      // Close progress dialog immediately after completion
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      try {
        progressNotifier.dispose();
      } catch (e) {
        // Ignore disposal errors
      }
    }
  }

  Future<void> _exportAsExcel(BuildContext context) async {
    // Show progress dialog
    final ValueNotifier<String> progressNotifier = ValueNotifier<String>('Preparing...');
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
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
                    color: const Color(0xFF2E7D32).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2E7D32),
                      strokeWidth: 3,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Generating Excel',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2C2C2C),
                  ),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<String>(
                  valueListenable: progressNotifier,
                  builder: (context, status, child) {
                    return Text(
                      status,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      await ExcelService.generateAttendanceReport(
        context,
        progressNotifier: progressNotifier,
      );
      
      // Close progress dialog immediately after completion
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate Excel report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      try {
        progressNotifier.dispose();
      } catch (e) {
        // Ignore disposal errors
      }
    }
  }

  Widget _buildMenuTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: const Color(0xFF1976D2),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
