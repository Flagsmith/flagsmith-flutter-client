// Steps for the Flagsmith SDK behavioural spec: https://github.com/Flagsmith/sdk-spec
import 'package:flagsmith/flagsmith.dart';

// Create the SDK client
Future<FlagsmithClient> createClient(String environmentKey, String apiUrl) =>
    FlagsmithClient.init(
      apiKey: environmentKey,
      config: FlagsmithConfig(baseURI: apiUrl),
    );

// When the application gets the environment flags
Future<List<Map<String, Object?>>> getEnvironmentFlags(
        FlagsmithClient flagsmith) async =>
    asSpecFlags(await flagsmith.getFeatureFlags());

// When the application gets the flags for identity "{identifier}" with traits:
Future<List<Map<String, Object?>>> getIdentityFlags(FlagsmithClient flagsmith,
        String identifier, Map<String, Object?> traits) async =>
    asSpecFlags(await flagsmith.getFeatureFlags(
      user: Identity(identifier: identifier),
      traits: [
        for (final MapEntry(:key, :value) in traits.entries)
          Trait(key: key, value: value),
      ],
    ));

List<Map<String, Object?>> asSpecFlags(List<Flag> flags) => [
      for (final flag in flags)
        {
          'feature': flag.feature.name,
          'enabled': flag.enabled,
          'value': flag.value,
        },
    ];
