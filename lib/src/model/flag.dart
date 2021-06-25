import 'dart:convert';
import 'dart:math';

import 'package:equatable/equatable.dart';
import '../extensions/string_x.dart';
import 'feature.dart';

class Flag extends Equatable {
  final int? id;
  final Feature feature;
  final String? stateValue;
  final bool? enabled;
  final int? environment;
  final int? identity;
  final int? featureSegment;
  @override
  List<Object?> get props => [
        id,
        feature,
        stateValue,
        enabled,
        environment,
        identity,
        featureSegment,
      ];
  @override
  bool get stringify => true;
  Flag(
    this.id,
    this.feature,
    this.stateValue,
    this.enabled,
    this.environment,
    this.identity,
    this.featureSegment,
  );
  Flag.named({
    this.id,
    required this.feature,
    this.stateValue,
    this.enabled,
    this.environment,
    this.identity,
    this.featureSegment,
  });

  Flag copyWith({
    int? id,
    Feature? feature,
    String? stateValue,
    bool? enabled,
    int? environment,
    int? identity,
    int? featureSegment,
  }) {
    return Flag(
      id ?? this.id,
      feature ?? this.feature,
      stateValue ?? this.stateValue,
      enabled ?? this.enabled,
      environment ?? this.environment,
      identity ?? this.identity,
      featureSegment ?? this.featureSegment,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'feature': feature.toMap(),
      'feature_state_value': stateValue,
      'enabled': enabled,
      'environment': environment,
      'identity': identity,
      'feature_segment': featureSegment,
    };
  }

  factory Flag.fromMap(Map<String, dynamic> map) {
    final _feature = Feature.fromMap(map['feature'] as Map<String, dynamic>);
    return Flag(
      map['id'] as int?,
      _feature,
      map['feature_state_value'].toString().normalize(),
      map['enabled'] as bool?,
      map['environment'] as int?,
      map['identity'] as int?,
      map['feature_segment'] as int?,
    );
  }

  String toJson() => json.encode(toMap());

  factory Flag.fromJson(String source) =>
      Flag.fromMap(json.decode(source) as Map<String, dynamic>);

  String get key => feature.name;
  @override
  String toString() {
    return 'F(${feature.name}:$enabled)';
  }

  static int _generateNum(int min, int max) =>
      min + Random().nextInt(max - min);
  static Flag seed(String featureName, {bool enabled = true, String? value}) {
    var id = _generateNum(1, 100);

    return Flag.named(
        id: id,
        stateValue: value,
        feature: Feature.named(
            id: id,
            name: featureName,
            createdDate:
                DateTime.now().add(
            Duration(days: _generateNum(0, 10)),
          ),
          initialValue: '',
          defaultValue: false,
        ),
        enabled: enabled);
  }
}
