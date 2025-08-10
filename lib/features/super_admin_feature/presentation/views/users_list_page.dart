import 'package:flutter/material.dart';
import '../../../admin_feature/presentation/views/widgets/users_list.dart';

class UsersListPage extends StatelessWidget {
  const UsersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Users List',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF667eea),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 4,
      ),
      body: const UsersList(),
    );
  }
}
