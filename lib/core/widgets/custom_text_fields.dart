import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    super.key,
    required TextEditingController workIdController,
    required this.labelText,
    this.obscureText,
    this.keyboardType,
  }) : _workIdController = workIdController;

  final TextEditingController _workIdController;
  final String labelText;
  final bool? obscureText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _workIdController,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      obscureText: obscureText ?? false,
      keyboardType: keyboardType,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required Field';
        }
        return null;
      },
    );
  }
}
