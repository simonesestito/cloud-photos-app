import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo_upload_result.freezed.dart';
part 'photo_upload_result.g.dart';

@freezed
class PhotoUploadResult with _$PhotoUploadResult {
  const factory PhotoUploadResult({
    @JsonKey(name: 'photo_id') required String photoId,
    @JsonKey(name: 'status') required String status,
    @JsonKey(name: 'timestamp') required String timestamp,
    @JsonKey(name: 'author_username') required String authorUsername,
    @JsonKey(name: 'error_message') String? errorMessage,
  }) = _PhotoUploadResult;

  factory PhotoUploadResult.fromJson(Map<String, dynamic> json) =>
      _$PhotoUploadResultFromJson(json);
}
