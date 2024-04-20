class PhotoUploadState {
  final double progress;
  final String? photoId;

  const PhotoUploadState._({required this.progress, this.photoId});

  factory PhotoUploadState.progress(double progress) {
    return PhotoUploadState._(progress: progress);
  }

  factory PhotoUploadState.complete(String photoId) {
    return PhotoUploadState._(progress: 1, photoId: photoId);
  }
}
