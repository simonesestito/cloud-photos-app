import 'package:cloud_photos_app/model/photo_upload_state.dart';
import 'package:cross_file/cross_file.dart';

abstract class PhotosRepository {
  static final PhotosRepository instance = _MockPhotosRepository();

  Uri getPhotoById(String id);

  Uri getThumbnailById(String id);

  Stream<PhotoUploadState> uploadPhoto(String username, XFile file);
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
    yield PhotoUploadState.complete('mock-photo-id');
  }
}

/// Randomize the image URL to avoid caching
String _randomizeUrl(String url) => url;
// => '$url?${DateTime.now().millisecondsSinceEpoch}';
