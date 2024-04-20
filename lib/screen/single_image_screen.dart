import 'package:cloud_photos_app/repository/photos_repository.dart';
import 'package:cloud_photos_app/widgets/window_title_bar.dart';
import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';

class SingleImageScreen extends StatelessWidget {
  static const kRouteName = '/singleImage';

  const SingleImageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final imageId = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Material(color: Theme.of(context).scaffoldBackgroundColor),
          ),
          SizedBox.expand(
            child: FancyShimmerImage(
              imageUrl:
                  PhotosRepository.instance.getPhotoById(imageId).toString(),
              boxFit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: createAppBarWithWindowBar(
              backgroundColor: Colors.white.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }
}
