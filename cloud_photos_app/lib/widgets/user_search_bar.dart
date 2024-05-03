import 'dart:async';

import 'package:cloud_photos_app/screen/login_screen.dart';
import 'package:cloud_photos_app/widgets/spacer.dart';
import 'package:flutter/material.dart';

typedef SearchCallback = FutureOr<void> Function(String);

class UserSearchBar extends StatelessWidget {
  static const _kSearchBarMaxWidth = 400.0;
  final SearchCallback onSearch;
  final _searchController = TextEditingController();

  UserSearchBar({required this.onSearch, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kSearchBarMaxWidth),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Search for a user',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SpacerBox(),
            SearchBar(
              controller: _searchController,
              hintText: 'Username',
              leading: const Icon(Icons.account_circle_outlined),
              onSubmitted: (_) => _onSearchPressed(context),
            ),
            const SpacerBox(),
            ElevatedButton.icon(
              onPressed: () => _onSearchPressed(context),
              icon: const Icon(Icons.search),
              label: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }

  FutureOr<void> _onSearchPressed(BuildContext context) async {
    final searchUsername = _searchController.value.text;
    final error = _validateSearchUsername(searchUsername);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
      return;
    }

    return onSearch(searchUsername);
  }

  String? _validateSearchUsername(String searchUsername) {
    if (searchUsername.isEmpty) {
      return 'Insert a username to search';
    }

    if (searchUsername.length < 3) {
      return 'Insert at least 3 characters';
    }

    if (!LoginScreen.usernameRegex.hasMatch(searchUsername)) {
      return 'Insert a valid username to search';
    }

    return null;
  }
}
