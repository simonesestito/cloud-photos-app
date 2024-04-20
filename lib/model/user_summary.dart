import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_summary.freezed.dart';
part 'user_summary.g.dart';

@freezed
class UserSummary with _$UserSummary {
  const factory UserSummary({
    required String username,
    required int postsCount,
  }) = _UserSummary;

  factory UserSummary.fromJson(Map<String, Object?> json) =>
      _$UserSummaryFromJson(json);
}
