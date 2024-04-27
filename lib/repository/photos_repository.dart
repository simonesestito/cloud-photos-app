import 'dart:async';

import 'package:cloud_photos_app/model/photo_upload_result.dart';
import 'package:cloud_photos_app/model/photo_upload_state.dart';
import 'package:cloud_photos_app/repository/aws.dart';
import 'package:cross_file/cross_file.dart';
import 'package:dio/dio.dart';

abstract class PhotosRepository {
  static final PhotosRepository instance = _AwsPhotosRepository();

  Uri getPhotoById(String id);

  Uri getThumbnailById(String id);

  Stream<PhotoUploadState> uploadPhoto(String username, XFile file);

  Future<PhotoUploadResult> getUploadStatus(String photoId);
}

class _MockPhotosRepository implements PhotosRepository {
  static const _mockPhotoUrl = 'https://via.placeholder.com/1400/2E7D32/FFF';
  static const _mockThumbnailUrl = 'https://via.placeholder.com/300/2E7D32/FFF';

  @override
  Uri getPhotoById(String id) => Uri.parse(_randomizeUrl(_mockPhotoUrl));

  @override
  Uri getThumbnailById(String id) =>
      Uri.parse(_randomizeUrl(_mockThumbnailUrl));

  @override
  Stream<PhotoUploadState> uploadPhoto(String username, XFile file) async* {
    // Fake progress every 20% in 350ms intervals
    yield PhotoUploadState.progress(0);
    for (var progress = 0.2; progress < 1; progress += 0.2) {
      await Future.delayed(const Duration(milliseconds: 350));
      yield PhotoUploadState.progress(progress);
    }
    yield PhotoUploadState.complete(PhotoUploadResult(
      photoId: 'mock-photo-id',
      status: 'PENDING',
      timestamp: DateTime.now().toIso8601String(),
      authorUsername: username,
    ));
  }

  @override
  Future<PhotoUploadResult> getUploadStatus(String photoId) async {
    await Future.delayed(const Duration(seconds: 3));
    return PhotoUploadResult(
      photoId: photoId,
      status: 'SUCCESS',
      timestamp: DateTime.now().toIso8601String(),
      authorUsername: 'mock-username',
    );
  }
}

class _AwsPhotosRepository implements PhotosRepository {
  @override
  Uri getPhotoById(String id) =>
      Uri.parse('https://resized-images-buck.s3.amazonaws.com/$id-comp.webp');

  @override
  Future<PhotoUploadResult> getUploadStatus(String photoId) async {
    final response = await awsHttpClient.get('/uploadStatus/$photoId');
    if (response.statusCode == 404) {
      throw Exception('Photo not found');
    }

    return PhotoUploadResult.fromJson(response.data);
  }

  @override
  Stream<PhotoUploadState> uploadPhoto(String username, XFile file) {
    final StreamController<PhotoUploadState> controller = StreamController();

    _uploadPhoto(
      username: username,
      file: file,
      uploadStateController: controller,
    );

    return controller.stream;
  }

  void _uploadPhoto({
    required String username,
    required XFile file,
    required StreamController<PhotoUploadState> uploadStateController,
  }) async {
    final multipartFile = await MultipartFile.fromFile(file.path);
    final fileForm = FormData.fromMap({
      'photo': multipartFile,
    });

    try {
      uploadStateController.add(PhotoUploadState.progress(0));

      final response = await awsHttpClient.post(
        '/photos',
        data: fileForm,
        options: Options(
          headers: {
            'Authorization': username,
          },
        ),
        onSendProgress: (sent, total) {
          final progress = sent / total;
          uploadStateController.add(PhotoUploadState.progress(progress));
        },
      );

      final photoUploadResult = PhotoUploadResult.fromJson(response.data);
      uploadStateController.add(PhotoUploadState.complete(photoUploadResult));
      uploadStateController.close();
    } catch (error, stackTrace) {
      uploadStateController.addError(error, stackTrace);
    }
  }

  @override
  Uri getThumbnailById(String id) => Uri.parse(
      'https://thumbnail-images-bucket.s3.amazonaws.com/$id-thumb.webp');
}

/// Randomize the image URL to avoid caching
String _randomizeUrl(String url) => url;
// => '$url?${DateTime.now().millisecondsSinceEpoch}';
