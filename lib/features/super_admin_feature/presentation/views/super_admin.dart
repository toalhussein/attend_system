import 'package:attend_system/features/admin_feature/presentation/views/widgets/table_calender.dart';
import 'package:attend_system/features/super_admin_feature/presentation/views/widgets/super_admin_app_bar.dart';
import 'package:attend_system/features/super_admin_feature/presentation/views/widgets/super_admin_drawer.dart';
import 'package:flutter/material.dart';
import '../../../admin_feature/presentation/views/widgets/admin_attendance_button.dart';
import 'users_list_page.dart';

class SuperAdminPage extends StatelessWidget {
  const SuperAdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SuperAdminAppBar(),
      drawer: const SuperAdminDrawer(),
      body: Column(
        children: [
          const CustomTableCalender(),
          const AdminAttendanceButton(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const UsersListPage(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.people,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'View Users List',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF667eea),
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: Colors.black26,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
