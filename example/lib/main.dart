import 'package:bullet_train/bullet_train.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

final GetIt getIt = GetIt.instance;

/// Prepare DI for [BulletTrainSampleApp]
Future<void> setup() async {
  final appDir = await getApplicationDocumentsDirectory();
  await appDir.create(recursive: true);
  final databasePath = join(appDir.path, 'bullt_train.db');

  getIt.registerSingleton<BulletTrainClient>(BulletTrainClient(
      apiKey: 'EBnVjhp7xvkT5oTLq4q7Ny',
      config: BulletTrainConfig(
          usePersistantStorage: true, persistantDatabasePath: databasePath)));

  getIt.registerFactory(() => FlagBloc(bt: getIt<BulletTrainClient>()));
  return null;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setup();
  runApp(BulletTrainSampleApp());
}

/// Simple [BulletTrainSampleApp]
class BulletTrainSampleApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bullet Train Example',
      theme: ThemeData(
        textTheme: GoogleFonts.varelaRoundTextTheme(
          Theme.of(context).textTheme,
        ),
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
              title: state.isEnabled('show_title_logo')
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.network(
                          'https://docs.bullet-train.io/images/logo.png',
                          width: 32,
                          height: 32,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(title)
                      ],
                    )
                  : Text(title),
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
                        var item = state.flags[index];
                        return SwitchListTile(
                            title: Text(item.feature.description),
                            subtitle: Text('name: ${item.feature.name}'),
                            value: item.enabled,
                            onChanged: (bool value) {});
                      },
                    ),
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

extension BuildContextX on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}

class CardTileWidget extends StatelessWidget {
  final Flag item;
  const CardTileWidget({Key key, @required this.item})
      : assert(item != null, 'missing data'),
        super(key: key);
  @override
  Widget build(BuildContext context) {
    var color =
        item.feature.name == 'color' ? Hexcolor(item.stateValue) : Colors.black;
    return Card(
      elevation: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.feature?.name,
            style: context.textTheme.headline5.copyWith(color: color),
          )
        ],
      ),
    );
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

  bool isEnabled(String flag) =>
      flags
          .firstWhere(
            (element) => element.feature.name == flag,
            orElse: () => null,
          )
          ?.enabled ??
      false;
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
