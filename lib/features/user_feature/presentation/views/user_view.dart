import 'package:attend_system/features/user_feature/presentation/views/widgets/employee_app_bar.dart';
import 'package:attend_system/features/user_feature/presentation/views/widgets/employee_body.dart';
import 'package:flutter/material.dart';

class EmployeePage extends StatelessWidget {
  const EmployeePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: EmployeeAppBar(),
      body: EmployeeBody(),
    );
  }
}
