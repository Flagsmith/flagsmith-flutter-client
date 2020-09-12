import 'package:bullet_train/bullet_train.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum LoadingState { isInitial, isLoading, isComplete }
enum FlagEvent {
  /// Notifies bloc to fetch flags from API
  initial,

  /// Notifies bloc to fetch flags from API
  fetch,
  // Notifies bloc to update user traits
  personalize
}

class FlagState {
  final LoadingState loading;
  final List<Flag> flags;
  FlagState({@required this.loading, this.flags}) : assert(loading != null);

  FlagState copyWith({LoadingState loading, List<Flag> flags}) {
    return FlagState(
        loading: loading ?? this.loading, flags: flags ?? this.flags);
  }

  @override
  String toString() => 'FlagState(loading: $loading, flags: $flags)';

  @override
  bool operator ==(Object o) {
    if (identical(this, o)) {
      return true;
    }

    return o is FlagState && o.loading == loading;
  }

  @override
  int get hashCode => loading.hashCode;

  factory FlagState.initial() =>
      FlagState(loading: LoadingState.isInitial, flags: []);
}

/// {@template counter_bloc}
/// A simple [Bloc] which manages an `int` as its state.
/// {@endtemplate}
class FlagBloc extends Bloc<FlagEvent, FlagState> {
  /// {@macro counter_bloc}
  final BulletTrainClient bt;
  FlagBloc({@required this.bt})
      : assert(bt != null),
        super(FlagState.initial());

  @override
  Stream<FlagState> mapEventToState(FlagEvent event) async* {
    switch (event) {
      case FlagEvent.initial:
        yield state.copyWith(loading: LoadingState.isInitial);
        break;
      case FlagEvent.fetch:
        yield state.copyWith(loading: LoadingState.isLoading);
        var result = await bt.getFeatureFlags();
        yield state.copyWith(loading: LoadingState.isComplete, flags: result);
        break;
      case FlagEvent.personalize:
        yield state.copyWith(loading: LoadingState.isLoading);
        await bt.updateTrait(FeatureUser(identifier: 'testUser'),
            Trait(key: 'age', value: '21'));
        break;
      default:
        addError(Exception('unsupported event'));
    }
  }
}
