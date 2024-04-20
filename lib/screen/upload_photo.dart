import 'package:cloud_photos_app/widgets/window_title_bar.dart';
import 'package:flutter/material.dart';

class UploadPhotoScreen extends StatelessWidget {
  static const kRouteName = '/uploadPhoto';

  const UploadPhotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBarWithWindowBar(title: const Text('Upload Photo')),
      body: const Placeholder(),
    );
  }
}
