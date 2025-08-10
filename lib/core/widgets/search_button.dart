// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api

import 'package:attend_system/features/admin_feature/presentation/views/widgets/user_search_delegate.dart';
import 'package:flutter/material.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showSearch(
          context: context,
          delegate: UserSearchDelegate(),
        );
      },
      icon: const Icon(Icons.search),
    );
  }
}
