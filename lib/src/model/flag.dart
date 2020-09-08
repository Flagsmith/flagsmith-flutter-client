import 'package:freezed_annotation/freezed_annotation.dart';
import 'feature.dart';
import 'model_utils.dart';

part 'flag.freezed.dart';
part 'flag.g.dart';

/// Representation of the Feature Flag in the system.
///
/// Feature can be either feature flag or remote config.
///
/// Feature flag - is a feature that you can turn on and off
/// e.g. en endpoint for an API or instant messaging for mobile app
///
/// Remote config - is a feature you can configure per env and holds value,
/// eg font size for image.

@freezed
abstract class Flag with _$Flag {
  const factory Flag(
      {@required
          int id,
      @required
          Feature feature,
      @JsonKey(
        name: 'feature_state_value',
        fromJson: stringFromInt,
      )
          String stateValue,
      @required
          bool enabled}) = _Flag;

  factory Flag.fromJson(Map<String, dynamic> json) => _$FlagFromJson(json);
}
