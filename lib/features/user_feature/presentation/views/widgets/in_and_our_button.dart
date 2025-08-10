import 'package:flutter/material.dart';

class InAndOurButton extends StatelessWidget {
  const InAndOurButton({
    super.key,
    required this.onPressed,
    required this.buttonName,
    required this.buttonColor,
  });

  final String buttonName;
  final Color buttonColor;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 40,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: buttonColor,
        foregroundColor: Colors.white,
      ),
      child: Text(
        buttonName,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }
}
