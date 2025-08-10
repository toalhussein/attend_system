import 'package:attend_system/core/widgets/custom_text_fields.dart';
import 'package:flutter/material.dart';

class EmployeeNumberField extends StatelessWidget {
  const EmployeeNumberField({
    super.key,
    required this.workIdController,
  });

  final TextEditingController workIdController;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      workIdController: workIdController,
      labelText: 'Employee Number',
      keyboardType: TextInputType.text,
    );
  }
}
