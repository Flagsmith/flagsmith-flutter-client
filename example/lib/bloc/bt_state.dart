part of 'bt_bloc.dart';

enum LoadingState { isInit, isLoding, isComplete }

@freezed
abstract class BtState with _$BtState {
  const factory BtState({@required LoadingState state, List<Flag> flags}) =
      _BtState;
  factory BtState.initial() => BtState(state: LoadingState.isInit, flags: []);
}
