import 'package:flagsmith/flagsmith.dart';
import 'package:flagsmith_storage_sharedpreferences/sharedpreferences_store.dart';
import 'package:get_it/get_it.dart';

import 'bloc/flag_bloc.dart';

/// Prepare DI for [FlagsmithSampleApp]
final GetIt getIt = GetIt.instance;
Future<void> setupPrefs() async {
  getIt.registerSingletonAsync<FlagsmithClient>(() async {
    final client = FlagsmithClient(
        apiKey: 'CoJErJUXmihfMDVwTzBff4',
        config: const FlagsmithConfig(
            storageType: StorageType.custom, isDebug: true),
        storage: InMemoryStorage());
    await client.initialize();
    return client;
  });

  getIt.registerSingletonWithDependencies(
      () => FlagBloc(fs: getIt<FlagsmithClient>()),
      dependsOn: [FlagsmithClient]);
  // getIt.registerFactory(() => FlagBloc(fs: getIt<FlagsmithClient>()));
}
