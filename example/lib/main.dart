import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:flagsmith/flagsmith.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_svg/flutter_svg.dart';

final GetIt getIt = GetIt.instance;
const String testFeature = 'show_title_logo';

/// Prepare DI for [FlagsmithSampleApp]

void setupPrefs() {
  getIt.registerSingleton<FlagsmithClient>(FlagsmithClient(
      apiKey: 'EBnVjhp7xvkT5oTLq4q7Ny',
      config: FlagsmithConfig(storeType: StoreType.persistant, isDebug: true)));

  getIt.registerFactory(() => FlagBloc(fs: getIt<FlagsmithClient>()));
  return null;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setupPrefs();
  runApp(FlagsmithSampleApp());
}

ThemeData theme = ThemeData(
  brightness: Brightness.light,
  primarySwatch: Colors.deepPurple,
  accentColor: Colors.deepPurpleAccent,
);

/// Simple [FlagsmithSampleApp]
class FlagsmithSampleApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flagsmith Example',
      theme: theme.copyWith(
        textTheme: GoogleFonts.varelaRoundTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: BlocProvider(
        create: (context) => getIt<FlagBloc>()
          ..add(FlagEvent.personalize)
          ..add(FlagEvent.initial),
        child: FlagsmithSampleScreen(title: 'Flagsmith Example'),
      ),
    );
  }
}

/// Sample screen
class FlagsmithSampleScreen extends StatelessWidget {
  // Screen title
  final String title;
  FlagsmithSampleScreen({Key? key, this.title = ''}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FlagBloc, FlagState>(
        listener: (context, state) {},
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: state.isEnabled(testFeature)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SvgPicture.network(
                          'https://www.flagsmith.com/static/images/nav-logo.svg',
                          height: 32,
                          fit: BoxFit.contain,
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          title + '/${state.isEnabled(testFeature)}',
                          style: Theme.of(context)
                              .textTheme
                              .caption
                              ?.copyWith(color: Theme.of(context).primaryColor),
                        ),
                      ],
                    )
                  : Text(
                      title + '/${state.isEnabled(testFeature)}',
                      style: Theme.of(context)
                          .textTheme
                          .headline5
                          ?.copyWith(color: Theme.of(context).primaryColor),
                    ),
              centerTitle: Platform.isIOS,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    border: Border(
                      bottom: BorderSide(
                          color: Theme.of(context).dividerColor, width: 1),
                    )),
              ),
            ),
            body: SafeArea(
              child: state.loading == LoadingState.isLoading
                  ? Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: () async {
                        context.read<FlagBloc>().add(FlagEvent.fetch);
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
                          return SwitchListTile.adaptive(
                              title: Text(item.feature?.description ??
                                  item.feature?.name ??
                                  'no description'),
                              subtitle: item.feature?.description != null
                                  ? Text(
                                      'feature: ${item.feature?.name}\ntype: ${item.feature != null ? describeEnum(item.feature!.type!) : ''}')
                                  : Text(
                                      'type: ${item.feature != null ? describeEnum(item.feature!.type!) : ''}'),
                              value: item.enabled ?? false,
                              onChanged: (bool value) {});
                        },
                      ),
                    ),
            ),

            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                FloatingActionButton(
                  mini: true,
                  onPressed: () =>
                      context.read<FlagBloc>().add(FlagEvent.toggle),
                  child: Icon(Icons.account_circle),
                ),
                FloatingActionButton.extended(
                  onPressed: () =>
                      context.read<FlagBloc>().add(FlagEvent.fetch),
                  tooltip: 'Fetch',
                  icon: Icon(Icons.add),
                  label: Text('Fetch'),
                ),
              ],
            ), // This trailing comma makes auto-formatting nicer for build methods.
          );
        });
  }
}

extension BuildContextX on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}

class CardTileWidget extends StatelessWidget {
  final Flag item;
  const CardTileWidget({Key? key, required this.item}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var color = item.feature?.name == 'color'
        ? HexColor(item.stateValue ?? '')
        : Colors.black;
    return Card(
      elevation: 1,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            item.feature?.name ?? '',
            style: context.textTheme.headline5?.copyWith(color: color),
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

  /// set stream listeners after fetch data
  register,

  /// Notifies bloc to fetch flags from API
  fetch,
  // Notifies bloc to update user traits
  personalize,

  // reload from storage
  reload,
  // toggle feature
  toggle
}

/// Simple [FlagState] for [FlagBloc]
class FlagState extends Equatable {
  // Loading state of bloc
  final LoadingState loading;
  // Loaded flag list
  final List<Flag> flags;

  @override
  List<Object> get props => [loading, flags];

  const FlagState({required this.loading, this.flags = const <Flag>[]});

  FlagState copyWith({LoadingState? loading, List<Flag>? flags}) {
    return FlagState(
        loading: loading ?? this.loading, flags: flags ?? this.flags);
  }

  /// Initial state
  factory FlagState.initial() =>
      FlagState(loading: LoadingState.isInitial, flags: []);

  bool isEnabled(String flag) {
    final found = flags.firstWhereOrNull(
        (element) => element.feature?.name == flag && element.enabled == true);
    return found?.enabled ?? false;
  }
}

/// A simple [Bloc] which manages an `FlagState` as its state.
class FlagBloc extends Bloc<FlagEvent, FlagState> {
  final FlagsmithClient fs;
  Stream<Flag>? _streamSubscription;
  FlagBloc({required this.fs}) : super(FlagState.initial());

  @override
  Stream<FlagState> mapEventToState(FlagEvent event) async* {
    switch (event) {
      case FlagEvent.initial:
        yield state.copyWith(loading: LoadingState.isInitial);
        add(FlagEvent.register);
        add(FlagEvent.fetch);

        break;
      case FlagEvent.fetch:
        yield state.copyWith(loading: LoadingState.isLoading);
        var result = await fs.getFeatureFlags();
        yield state.copyWith(loading: LoadingState.isComplete, flags: result);
        add(FlagEvent.register);
        break;
      case FlagEvent.reload:
        yield state.copyWith(loading: LoadingState.isLoading);
        var result = await fs.getFeatureFlags(reload: false);
        yield state.copyWith(loading: LoadingState.isComplete, flags: result);
        break;
      case FlagEvent.personalize:
        yield state.copyWith(loading: LoadingState.isLoading);
        await fs.updateTrait(FeatureUser(identifier: 'testUser'),
            Trait(key: 'age', value: '21'));
        break;
      case FlagEvent.register:
        _streamSubscription ??= fs.stream(testFeature);
        _streamSubscription?.listen((event) {
          log('LISTEN: ${event.feature?.name} => ${event.enabled}');
          add(FlagEvent.reload);
        });

        break;
      case FlagEvent.toggle:
        await fs.testToggle(testFeature);
        break;
      default:
        addError(Exception('unsupported event'));
    }
  }

  Future<bool> isEnabled(String featureName, {FeatureUser? user}) =>
      fs.hasFeatureFlag(featureName, user: user);

  @override
  Future<void> close() {
    // _behaviorSubject.cancel();
    return super.close();
  }
}
