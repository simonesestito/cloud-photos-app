abstract class PhotosRepository {
  static final PhotosRepository instance = _MockPhotosRepository();

  Uri getPhotoById(String id);

  Uri getThumbnailById(String id);
}

class _MockPhotosRepository implements PhotosRepository {
  static const _mockPhotoUrl = 'https://via.placeholder.com/1400';
  static const _mockThumbnailUrl = 'https://via.placeholder.com/300';

  @override
  Uri getPhotoById(String id) => Uri.parse(_randomizeUrl(_mockPhotoUrl));

  @override
  Uri getThumbnailById(String id) =>
      Uri.parse(_randomizeUrl(_mockThumbnailUrl));
}

/// Randomize the image URL to avoid caching
String _randomizeUrl(String url) =>
    '$url?${DateTime.now().millisecondsSinceEpoch}';
