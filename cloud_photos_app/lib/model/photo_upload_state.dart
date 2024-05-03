import 'package:cloud_photos_app/model/photo_upload_result.dart';

class PhotoUploadState {
  final double progress;
  final PhotoUploadResult? photoUploadResult;

  const PhotoUploadState._({required this.progress, this.photoUploadResult});

  factory PhotoUploadState.progress(double progress) {
    return PhotoUploadState._(progress: progress);
  }

  factory PhotoUploadState.complete(PhotoUploadResult photoUploadResult) {
    return PhotoUploadState._(
        progress: 1, photoUploadResult: photoUploadResult);
  }
}
