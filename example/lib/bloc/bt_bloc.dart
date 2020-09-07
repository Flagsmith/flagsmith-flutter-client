import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bullet_train/bullet_train.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'bt_event.dart';
part 'bt_state.dart';
part 'bt_bloc.freezed.dart';

class BtBloc extends Bloc<BtEvent, BtState> {
  final BulletTrainClient bt;
  BtBloc({@required this.bt})
      : assert(bt != null),
        super(BtState.initial());

  @override
  Stream<BtState> mapEventToState(
    BtEvent event,
  ) async* {
    yield* event.map(started: (_) async* {
      await bt.postUserTraits(
          FeatureUser(identifier: 'testUser'), Trait(key: 'age', value: '21'));
    }, getFeatures: (_) async* {
      yield state.copyWith(state: LoadingState.isLoding);
      var result = await bt.getFeatureFlags();
      yield state.copyWith(state: LoadingState.isComplete, flags: result);
    }, hasFeature: (e) async* {
      var result = bt.hasFeatureFlag(e.value);
    });
  }
}
