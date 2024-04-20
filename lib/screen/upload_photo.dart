import 'package:cloud_photos_app/preferences/preferences.dart';
import 'package:cloud_photos_app/repository/photos_repository.dart';
import 'package:cloud_photos_app/screen/single_image_screen.dart';
import 'package:cloud_photos_app/widgets/file_drop_area.dart';
import 'package:cloud_photos_app/widgets/window_title_bar.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

class UploadPhotoScreen extends StatefulWidget {
  static const kRouteName = '/uploadPhoto';

  const UploadPhotoScreen({super.key});

  @override
  State<UploadPhotoScreen> createState() => _UploadPhotoScreenState();
}

class _UploadPhotoScreenState extends State<UploadPhotoScreen> {
  double _progress = -1;
  String? _photoId;

  bool get _isPickingFile => _progress == -1;

  bool get _isUploading => _progress >= 0 && _progress < 1;

  bool get _isUploadComplete => _progress == 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: createAppBarWithWindowBar(
        title: const Text('Upload Photo'),
        // Avoid popping the route when a photo is being uploaded
        automaticallyImplyLeading: !_isUploading,
      ),
      body: PopScope(
        // Avoid popping the route when a photo is being uploaded
        canPop: !_isUploading,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isPickingFile) return _buildFilePicker();
    if (_isUploading) return _buildUploadProgress();
    if (_isUploadComplete) return _buildUploadComplete();
    throw StateError('Invalid state: {progress = $_progress}');
  }

  Widget _buildFilePicker() => Padding(
        padding: const EdgeInsets.all(48),
        child: FileDropArea(onFileDrop: _onFileUpload),
      );

  void _onFileUpload(XFile file) {
    setState(() {
      _progress = 0;
    });

    final myUsername = Preferences.instance.getLoginName()!;
    PhotosRepository.instance.uploadPhoto(myUsername, file).listen((progress) {
      setState(() {
        _progress = progress.progress;
        _photoId = progress.photoId;
      });
    });
  }

  Widget _buildUploadProgress() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(value: _progress),
            const SizedBox(height: 16),
            Text('${(_progress * 100).toStringAsFixed(0)}%'),
          ],
        ),
      );

  Widget _buildUploadComplete() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _onOpenUploadedPhoto,
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Uploaded Photo'),
            ),
          ],
        ),
      );

  void _onOpenUploadedPhoto() {
    if (_photoId == null || !mounted) return;
    Navigator.pushReplacementNamed(
      context,
      SingleImageScreen.kRouteName,
      arguments: _photoId!,
    );
  }
}
