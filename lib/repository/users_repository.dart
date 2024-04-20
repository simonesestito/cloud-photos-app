import 'package:cloud_photos_app/model/user.dart';
import 'package:cloud_photos_app/model/user_summary.dart';

abstract class UserRepository {
  static final UserRepository instance = _MockUserRepository();

  Future<List<UserSummary>> searchUser(String username);

  Future<User?> getUserByName(String username);
}

class _MockUserRepository implements UserRepository {
  final users = const [
    User(
      username: 'ciccio',
      postIds: ['aaa', 'bbb', 'ccc'],
    ),
    User(
      username: 'ciccino',
      postIds: ['ddd', 'eee'],
    ),
    User(
      username: 'mario',
      postIds: ['mmm', 'nnn'],
    ),
  ];

  @override
  Future<List<UserSummary>> searchUser(String username) async {
    await loading();
    return users
        .where((user) => user.username.contains(username))
        .map((user) => UserSummary(
              username: user.username,
              postsCount: user.postIds.length,
            ))
        .toList();
  }

  @override
  Future<User?> getUserByName(String username) async {
    await loading();
    return users.where((user) => user.username == username).firstOrNull;
  }

  Future<void> loading() => Future.delayed(const Duration(seconds: 1));
}
