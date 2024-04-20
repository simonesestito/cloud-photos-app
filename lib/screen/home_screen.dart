import 'package:cloud_photos_app/preferences/preferences.dart';
import 'package:cloud_photos_app/screen/login_screen.dart';
import 'package:cloud_photos_app/screen/user_search_results_screen.dart';
import 'package:cloud_photos_app/widgets/user_search_bar.dart';
import 'package:cloud_photos_app/widgets/window_title_bar.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  static const kRouteName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String loginName = Preferences.instance.getLoginName()!;
    return Scaffold(
      appBar: createAppBarWithWindowBar(
        title: Text('Hi, $loginName!'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _onLogout(context),
          ),
        ],
      ),
      body: UserSearchBar(
        onSearch: (username) => Navigator.pushNamed(
          context,
          UserSearchResultsScreen.kRouteName,
          arguments: username,
        ),
      ),
    );
  }

  Future<void> _onLogout(BuildContext context) async {
    await Preferences.instance.removeLoginName();
    if (context.mounted) {
      Navigator.of(context).pushReplacementNamed(LoginScreen.kRouteName);
    }
  }
}
