import 'package:json_annotation/json_annotation.dart';

enum FlagType {
  @JsonValue('CONFIG')
  config,
  @JsonValue('FLAG')
  flag
}
