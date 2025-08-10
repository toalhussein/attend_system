import 'package:flutter/material.dart';

import 'create_user.dart';

class CustomDeleteAndCrateUserButton extends StatelessWidget {
  const CustomDeleteAndCrateUserButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.add),
      title: const Text('Create User'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:  (context) => const CreateUserPage(),
          ),
        );
      },
    );
  }
}
