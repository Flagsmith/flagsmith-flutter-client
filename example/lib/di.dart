import 'package:flagsmith/flagsmith.dart';
import 'package:flagsmith_storage/flagsmith_storage_sharedpreferences.dart';
import 'package:get_it/get_it.dart';

import 'bloc/flag_bloc.dart';

/// Prepare DI for [FlagsmithSampleApp]
final GetIt getIt = GetIt.instance;

Future<void> setupPrefs() async {
  getIt.registerSingletonAsync<FlagsmithClient>(() async {
    final client = FlagsmithClient(
        apiKey: 'Ufj74JHbHFevTt9v6Bq3ru',
        config: const FlagsmithConfig(
          storageType: StorageType.custom,
          isDebug: true,
          enableRealtimeUpdates: true,
        ),
        storage: FlagsmithSharedPreferenceStore());
    await client.initialize();
    return client;
  });

  getIt.registerSingletonWithDependencies(
      () => FlagBloc(fs: getIt<FlagsmithClient>()),
      dependsOn: [FlagsmithClient]);
  // getIt.registerFactory(() => FlagBloc(fs: getIt<FlagsmithClient>()));
}
