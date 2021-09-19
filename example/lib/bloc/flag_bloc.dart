import '../enum/loading_state.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import 'package:flagsmith/flagsmith.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../main.dart';
part 'flag_event.dart';
part 'flag_state.dart';

/// A simple [Bloc] which manages an `FlagState` as its state.
class FlagBloc extends Bloc<FlagEvent, FlagState> {
  final FlagsmithClient fs;
  Stream<Flag>? _streamSubscription;
  FlagBloc({required this.fs}) : super(FlagState.initial());

  @override
  Stream<FlagState> mapEventToState(FlagEvent event) async* {
    switch (event.runtimeType) {
      case InitFlagEvent:
        yield state.copyWith(loading: LoadingState.isInitial);
        add(RegisterFlagEvent());
        break;
      case FetchFlagEvent:
        yield state.copyWith(loading: LoadingState.isLoading);
        var result = await fs.getFeatureFlags(user: state.identity);
        yield state.copyWith(loading: LoadingState.isComplete, flags: result);
        add(RegisterFlagEvent());
        break;
      case ReloadFlagEvent:
        yield state.copyWith(loading: LoadingState.isLoading);
        var result =
            await fs.getFeatureFlags(user: state.identity, reload: false);
        yield state.copyWith(loading: LoadingState.isComplete, flags: result);
        break;
      case PersonalizeFlagEvent:
        yield state.copyWith(loading: LoadingState.isLoading);
        await fs.createTrait(
            value: TraitWithIdentity(
          identity: Identity(identifier: 'testUser'),
          key: 'age',
          value: '21',
        ));
        add(ReloadFlagEvent());
        break;
      case RegisterFlagEvent:
        _streamSubscription ??= fs.stream(testFeature);
        _streamSubscription?.listen((event) {
          log('LISTEN: ${event.feature.name} => ${event.enabled}');
          add(ReloadFlagEvent());
        });
        add(ReloadFlagEvent());
        break;
      case ToggleFlagEvent:
        await fs.testToggle(testFeature);
        break;
      case ChangeIdentityFlagEvent:
        final value = event as ChangeIdentityFlagEvent;
        yield state.copyWith(
          loading: LoadingState.isLoading,
          identity: Identity(identifier: value.identifier),
        );
        add(ReloadFlagEvent());
        break;
      case RemoveIdentityFlagEvent:
        yield state.copyWith(
          loading: LoadingState.isLoading,
          identity: null,
        );
        add(ReloadFlagEvent());
        break;
      default:
        addError(Exception('unsupported event'));
    }
  }

  Future<bool> isEnabled(String featureName, {Identity? user}) =>
      fs.hasFeatureFlag(featureName, user: user);

  @override
  Future<void> close() {
    return super.close();
  }
}
