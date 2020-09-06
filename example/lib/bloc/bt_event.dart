part of 'bt_bloc.dart';

@freezed
abstract class BtEvent with _$BtEvent {
  const factory BtEvent.started() = _Started;
  const factory BtEvent.getFeatures() = _GetFeatures;
  const factory BtEvent.hasFeature(String value) = _HasFeature;
}
