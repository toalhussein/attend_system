import 'package:attend_system/core/widgets/custom_app_bar.dart';
import 'package:attend_system/features/login_feature/presentation/views/login_view.dart';
import 'package:attend_system/main.dart';
import 'package:flutter/material.dart';

class EmployeeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const EmployeeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: 'Employee Page',
      actions: [
        IconButton(
          onPressed: () {
            LocalStorage.userData.remove('id');
            LocalStorage.userData.remove('role');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          },
          icon: const Icon(Icons.login),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
