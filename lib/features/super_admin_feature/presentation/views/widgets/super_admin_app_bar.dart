import 'package:attend_system/core/widgets/custom_app_bar.dart';
import 'package:attend_system/core/widgets/search_button.dart';
import 'package:flutter/material.dart';

class SuperAdminAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SuperAdminAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomAppBar(
      title: 'SuperAdmin',
      actions: [
        SearchButton(),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
