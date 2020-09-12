import 'package:bullet_train/bullet_train.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hexcolor/hexcolor.dart';

final GetIt getIt = GetIt.instance;

/// Prepare DI for [BulletTrainSampleApp]
void setup() {
  getIt.registerSingleton<BulletTrainClient>(BulletTrainClient(
      apiKey: 'EBnVjhp7xvkT5oTLq4q7Ny',
      config: BulletTrainConfig(usePersistantStorage: true)));

  getIt.registerFactory(
      () => FlagBloc(bt: GetIt.instance.get<BulletTrainClient>()));
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setup();
  runApp(BulletTrainSampleApp());
}

/// Simple [BulletTrainSampleApp]
class BulletTrainSampleApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 35, 61, 83),
        accentColor: Color(0xff1c9997),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: BlocProvider(
        create: (context) =>
            getIt<FlagBloc>()..add(FlagEvent.personalize)..add(FlagEvent.fetch),
        child: BulletTrainSampleScreen(title: 'Bullet Train Example'),
      ),
    );
  }
}

/// Sample screen
class BulletTrainSampleScreen extends StatelessWidget {
  // Screen title
  final String title;
  BulletTrainSampleScreen({Key key, this.title}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FlagBloc, FlagState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(title),
              centerTitle: true,
            ),
            body: state.loading == LoadingState.isLoading
                ? Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: () async {
                      context.bloc<FlagBloc>().add(FlagEvent.fetch);
                      return null;
                    },
                    child: ListView.separated(
                        padding: const EdgeInsets.all(8.0),
                        separatorBuilder: (context, index) => Divider(
                              height: 1,
                              indent: 16,
                            ),
                        itemCount: state.flags.length,
                        itemBuilder: (context, index) {
                          var color = state.flags[index].feature.name == 'color'
                              ? Hexcolor(state.flags[index].stateValue)
                              : Colors.black;

                          return SwitchListTile(
                            title: Text(
                              '${state.flags[index].feature.name} | ${state.flags[index].stateValue}',
                              style: TextStyle(color: color),
                            ),
                            subtitle: Text(
                                '${state.flags[index].enabled ? 'ON' : 'OFF'} ${state.flags[index].toString()}'),
                            value: state.flags[index].enabled,
                            onChanged: null,
                          );
                        }),
                  ),
            floatingActionButton: FloatingActionButton.extended(
              onPressed: () => context.bloc<FlagBloc>().add(FlagEvent.fetch),
              tooltip: 'Fetch',
              icon: Icon(Icons.add),
              label: Text('Fetch'),
            ),

            // This trailing comma makes auto-formatting nicer for build methods.
          );
        });
  }
}

/// State of network call for UI
enum LoadingState { isInitial, isLoading, isComplete }

/// Simple [FlagEvent] enum for [FlagBloc]
enum FlagEvent {
  /// Notifies bloc to fetch flags from API
  initial,

  /// Notifies bloc to fetch flags from API
  fetch,
  // Notifies bloc to update user traits
  personalize
}

/// Simple [FlagState] for [FlagBloc]
class FlagState {
  // Loading state of bloc
  final LoadingState loading;
  // Loaded flag list
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

  /// Initial state
  factory FlagState.initial() =>
      FlagState(loading: LoadingState.isInitial, flags: []);
}

/// A simple [Bloc] which manages an `FlagState` as its state.
class FlagBloc extends Bloc<FlagEvent, FlagState> {
  final BulletTrainClient bt;
  FlagBloc({@required this.bt})
      : assert(bt != null),
        super(FlagState.initial());

  @override
  Stream<FlagState> mapEventToState(FlagEvent event) async* {
    switch (event) {
      case FlagEvent.initial:
        yield state.copyWith(loading: LoadingState.isInitial);
        add(FlagEvent.fetch);
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
