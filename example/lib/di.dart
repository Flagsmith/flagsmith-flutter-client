import 'package:flagsmith/flagsmith.dart';
import 'package:get_it/get_it.dart';

import 'bloc/flag_bloc.dart';

/// Prepare DI for [FlagsmithSampleApp]
final GetIt getIt = GetIt.instance;
void setupPrefs() {
  getIt.registerSingleton<FlagsmithClient>(FlagsmithClient(
      apiKey: 'CoJErJUXmihfMDVwTzBff4',
      config: FlagsmithConfig(storeType: StoreType.persistant, isDebug: true)));

  getIt.registerFactory(() => FlagBloc(fs: getIt<FlagsmithClient>()));
  return null;
}
