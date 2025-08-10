// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';

class CustomNavigationTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? page;
  final void Function()? onTap;

  const CustomNavigationTile({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.page,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap ??
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page!),
            );
          },
    );
  }
}
