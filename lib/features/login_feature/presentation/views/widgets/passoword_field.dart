import 'package:attend_system/core/widgets/custom_text_fields.dart';
import 'package:flutter/material.dart';

class PassowordField extends StatelessWidget {
  const PassowordField({
    super.key,
    required this.passwordController,
  });

  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: CustomTextField(
        workIdController: passwordController,
        labelText: 'Password',
        obscureText: true,
      ),
    );
  }
}
