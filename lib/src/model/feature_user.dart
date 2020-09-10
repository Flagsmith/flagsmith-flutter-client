import 'package:freezed_annotation/freezed_annotation.dart';

part 'feature_user.freezed.dart';
part 'feature_user.g.dart';

@freezed
abstract class FeatureUser with _$FeatureUser {
  const factory FeatureUser({@required String identifier}) = _FeatureUser;

  factory FeatureUser.fromJson(Map<String, dynamic> json) =>
      _$FeatureUserFromJson(json);
}
