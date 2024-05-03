import 'package:cloud_photos_app/model/user_summary.dart';
import 'package:cloud_photos_app/repository/users_repository.dart';
import 'package:cloud_photos_app/screen/user_details_screen.dart';
import 'package:cloud_photos_app/widgets/empty_view.dart';
import 'package:cloud_photos_app/widgets/error.dart';
import 'package:cloud_photos_app/widgets/loading.dart';
import 'package:cloud_photos_app/widgets/window_title_bar.dart';
import 'package:flutter/material.dart';

class UserSearchResultsScreen extends StatelessWidget {
  static const kRouteName = '/searchUser';

  const UserSearchResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final username = ModalRoute.of(context)!.settings.arguments as String;
    final searchRequest = UserRepository.instance.searchUser(username);

    return Scaffold(
      appBar: createAppBarWithWindowBar(
        title: const Text('Search Results'),
      ),
      body: FutureBuilder<List<UserSummary>>(
        future: searchRequest,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.isEmpty) {
            return const ListEmptyView();
          } else if (snapshot.hasData) {
            return _buildUsersList(snapshot.data!);
          } else if (snapshot.hasError) {
            return AppErrorWidget(snapshot.error!);
          } else {
            return const AppLoading();
          }
        },
      ),
    );
  }

  Widget _buildUsersList(List<UserSummary> users) {
    return ListView.separated(
      itemCount: users.length,
      itemBuilder: (context, i) => ListTile(
        leading: const Icon(Icons.account_circle),
        title: Text(users[i].username),
        subtitle: Text('Published ${users[i].postsCount} posts'),
        onTap: () => _onUserTap(context, users[i]),
      ),
      separatorBuilder: (context, _) => const Divider(),
    );
  }

  void _onUserTap(BuildContext context, UserSummary user) {
    final username = user.username;
    Navigator.pushNamed(
      context,
      UserDetailsScreen.kRouteName,
      arguments: username,
    );
  }
}
