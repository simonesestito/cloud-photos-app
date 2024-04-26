import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_upload_result.freezed.dart';
part 'photo_upload_result.g.dart';

@freezed
class PhotoUploadResult with _$PhotoUploadResult {
  const factory PhotoUploadResult({
    required String photoId,
    required String status,
    required String timestamp,
    required String authorUsername,
    String? errorMessage,
  }) = _PhotoUploadResult;

  factory PhotoUploadResult.fromJson(Map<String, dynamic> json) =>
      _$PhotoUploadResultFromJson(json);
}
