import 'package:attend_system/core/widgets/custom_app_bar.dart';
import 'package:attend_system/core/widgets/search_button.dart';
import 'package:attend_system/features/admin_feature/presentation/views/widgets/users_list.dart';
import 'package:attend_system/features/login_feature/presentation/views/login_view.dart';
import 'package:attend_system/main.dart';
import 'package:flutter/material.dart';
import 'widgets/admin_attendance_button.dart';
import 'widgets/table_calender.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Admin Page',
        actions: [
          const SearchButton(),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              LocalStorage.userData.remove('id');
              LocalStorage.userData.remove('role');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
          ),
        ],
      ),
      body: const Column(
        children: [
           CustomTableCalender(),
           AdminAttendanceButton(),
           Expanded(
             child: UsersList(),
           ),
         ],
       ),
    );
  }
}
