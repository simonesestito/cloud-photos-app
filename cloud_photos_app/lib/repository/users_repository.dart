import 'package:cloud_photos_app/model/user.dart';
import 'package:cloud_photos_app/model/user_summary.dart';
import 'package:cloud_photos_app/repository/aws.dart';

abstract class UserRepository {
  static final UserRepository instance = _AwsUserRepository();

  Future<List<UserSummary>> searchUser(String username);

  Future<User?> getUserByName(String username);
}

// class _MockUserRepository implements UserRepository {
//   final users = const [
//     User(
//       username: 'ciccio',
//       postIds: ['aaa', 'bbb', 'ccc'],
//     ),
//     User(
//       username: 'ciccino',
//       postIds: ['ddd', 'eee'],
//     ),
//     User(
//       username: 'mario',
//       postIds: ['mmm', 'nnn'],
//     ),
//   ];
//
//   @override
//   Future<List<UserSummary>> searchUser(String username) async {
//     await loading();
//     return users
//         .where((user) => user.username.contains(username))
//         .map((user) => UserSummary(
//               username: user.username,
//               postsCount: user.postIds.length,
//             ))
//         .toList();
//   }
//
//   @override
//   Future<User?> getUserByName(String username) async {
//     await loading();
//     return users.where((user) => user.username == username).firstOrNull;
//   }
//
//   Future<void> loading() => Future.delayed(const Duration(seconds: 1));
// }

class _AwsUserRepository implements UserRepository {
  @override
  Future<User?> getUserByName(String username) async {
    final response = await awsHttpClient.get('/users/$username');
    if (response.statusCode == 404) {
      return null;
    }

    return User.fromJson(response.data);
  }

  @override
  Future<List<UserSummary>> searchUser(String username) async {
    final response = await awsHttpClient.get('/users?username=$username');
    return (response.data as List)
        .map((json) => UserSummary.fromJson(json))
        .toList();
  }

}
