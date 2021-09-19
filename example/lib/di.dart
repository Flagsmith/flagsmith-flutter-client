import 'package:flagsmith/flagsmith.dart';
import 'package:get_it/get_it.dart';

import 'bloc/flag_bloc.dart';

/// Prepare DI for [FlagsmithSampleApp]
final GetIt getIt = GetIt.instance;
Future<void> setupPrefs() async {
  getIt.registerSingletonAsync<FlagsmithClient>(() async {
    final client = FlagsmithClient(
      apiKey: 'CoJErJUXmihfMDVwTzBff4',
      config: FlagsmithConfig(storeType: StoreType.persistant, isDebug: true),
    );
    await client.initialize();
    return client;
  });
  
  getIt.registerSingletonWithDependencies(
      () => FlagBloc(fs: getIt<FlagsmithClient>()),
      dependsOn: [FlagsmithClient]);
  // getIt.registerFactory(() => FlagBloc(fs: getIt<FlagsmithClient>()));
}
