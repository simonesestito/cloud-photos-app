import 'package:cloud_photos_app/model/photo_upload_result.dart';
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
  PhotoUploadResult? _photoUploadResult;

  bool get _isPickingFile => _progress == -1;

  bool get _isUploading =>
      _progress >= 0 && _progress < 1 ||
      (_progress == 1 && _photoUploadResult == null);

  bool get _isPending => _photoUploadResult?.status == 'PENDING';

  bool get _isUploadComplete => _photoUploadResult?.status == 'SUCCESS';

  bool get _isError => _photoUploadResult?.status == 'ERROR';

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
    if (_isPending) return _buildUploadPending();
    if (_isUploadComplete) return _buildUploadComplete();
    if (_isError) return _buildError();
    throw StateError('Invalid state: $_photoUploadResult');
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
      debugPrint('[UploadPhotoScreen] Progress: ${progress.progress}');
      debugPrint(
          '[UploadPhotoScreen] Photo upload result: ${progress.photoUploadResult}');
      setState(() {
        _progress = progress.progress;
        _photoUploadResult = progress.photoUploadResult;
      });
    })
      ..onDone(() async {
        // Every 3 seconds, check if the photo is uploaded
        debugPrint('[UploadPhotoScreen] Starting upload status check');
        debugPrint(
            '[UploadPhotoScreen] Photo upload status: ${_photoUploadResult?.status}');
        debugPrint('[UploadPhotoScreen] Widget mounted: $mounted');
        while (mounted &&
          (_photoUploadResult == null ||
              _photoUploadResult?.status == 'PENDING')) {
        await Future.delayed(const Duration(seconds: 3));
          if (!mounted) {
            debugPrint(
                '[UploadPhotoScreen] Widget unmounted, stopping upload status check');
            return;
          }

          final photoId = _photoUploadResult!.photoId;
        final status = await PhotosRepository.instance.getUploadStatus(photoId);
          debugPrint('[UploadPhotoScreen] Photo upload status: $status');
          if (mounted) {
          setState(() {
            _photoUploadResult = status;
          });
        }
      }
      })
      ..onError((error, stackTrace) {
        debugPrint('Error while uploading photo: $error');
        debugPrintStack(stackTrace: stackTrace);
        setState(() {
          _photoUploadResult = PhotoUploadResult(
            photoId: _photoUploadResult?.photoId ?? '',
            status: 'ERROR',
            timestamp: _photoUploadResult?.timestamp ?? '',
            authorUsername: myUsername,
            errorMessage: 'Error during upload. Please try again.',
          );
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

  Widget _buildUploadPending() => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Your photo is otoUploadbeing elaborated. Please wait.'),
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

  Widget _buildError() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              _photoUploadResult!.errorMessage ??
                  'An error occurred while uploading the photo.',
            ),
          ],
        ),
      );

  void _onOpenUploadedPhoto() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      SingleImageScreen.kRouteName,
      arguments: _photoUploadResult!.photoId,
    );
  }
}
