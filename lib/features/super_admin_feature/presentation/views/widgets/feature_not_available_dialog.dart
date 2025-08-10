// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class FeatureNotAvailableDialog extends StatelessWidget {
  const FeatureNotAvailableDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Feature Not Available'),
      content: const Text('This feature is not available now.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
