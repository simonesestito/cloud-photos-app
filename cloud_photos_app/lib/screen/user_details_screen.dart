import 'package:cloud_photos_app/model/user.dart';
import 'package:cloud_photos_app/repository/photos_repository.dart';
import 'package:cloud_photos_app/repository/users_repository.dart';
import 'package:cloud_photos_app/screen/single_image_screen.dart';
import 'package:cloud_photos_app/widgets/error.dart';
import 'package:cloud_photos_app/widgets/loading.dart';
import 'package:cloud_photos_app/widgets/window_title_bar.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';

class UserDetailsScreen extends StatelessWidget {
  static const kRouteName = '/userDetails';

  const UserDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final username = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: createAppBarWithWindowBar(title: Text(username)),
      body: FutureBuilder<User?>(
        future: UserRepository.instance.getUserByName(username),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return AppErrorWidget(snapshot.error!);
          } else if (snapshot.hasData) {
            return _buildUserDetails(snapshot.data!);
          } else if (snapshot.connectionState == ConnectionState.done) {
            return const AppErrorWidget('User not found');
          } else {
            return const AppLoading();
          }
        },
      ),
    );
  }

  Widget _buildUserDetails(User user) {
    return GridView.builder(
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemCount: user.postIds.length,
      itemBuilder: (context, i) =>
          _buildImageThumbnail(context, user.postIds[i]),
    );
  }

  Widget _buildImageThumbnail(BuildContext context, String imageId) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        child: FancyShimmerImage(
          imageUrl:
              PhotosRepository.instance.getThumbnailById(imageId).toString(),
          boxFit: BoxFit.cover,
        ),
        onTap: () => _onImageTap(context, imageId),
      ),
    );
  }

  void _onImageTap(BuildContext context, String imageId) {
    Navigator.pushNamed(
      context,
      SingleImageScreen.kRouteName,
      arguments: imageId,
    );
  }
}
