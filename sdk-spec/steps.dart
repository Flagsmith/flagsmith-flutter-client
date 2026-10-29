// Steps for the Flagsmith SDK behavioural spec: https://github.com/Flagsmith/sdk-spec
import 'package:flagsmith/flagsmith.dart';

// Create the SDK client
Future<FlagsmithClient> createClient(String environmentKey, String apiUrl) =>
    FlagsmithClient.init(
      apiKey: environmentKey,
      config: FlagsmithConfig(baseURI: apiUrl),
    );

// Create the SDK client with events enabled
Future<FlagsmithClient> createClientWithEvents(
        String environmentKey, String apiUrl, String eventsApiUrl) =>
    FlagsmithClient.init(
      apiKey: environmentKey,
      config: FlagsmithConfig(
        baseURI: apiUrl,
        enableEvents: true,
        eventsURI: eventsApiUrl,
      ),
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

// When the application gets the experiment flag "{feature}" for identity "{identifier}" with traits:
Future<List<Map<String, Object?>>> getExperimentFlag(FlagsmithClient flagsmith,
    String feature, String identifier, Map<String, Object?> traits) async {
  final flag = await flagsmith.getExperimentFlag(
    feature,
    user: Identity(identifier: identifier),
    traits: [
      for (final MapEntry(:key, :value) in traits.entries)
        Trait(key: key, value: value),
    ],
  );
  return asSpecFlags([if (flag != null) flag]);
}

// When the application tracks event "{event}" for identity "{identifier}" with value {value} and metadata:
void trackEvent(FlagsmithClient flagsmith, String event, String identifier,
        Object? value, Map<String, Object?> metadata) =>
    flagsmith.trackEvent(
      event,
      user: Identity(identifier: identifier),
      value: value,
      metadata: metadata,
    );

// When the application tracks an exposure of feature "{feature}" for identity "{identifier}" with value {value} and metadata:
void trackExposureEvent(FlagsmithClient flagsmith, String feature,
        String identifier, Object? value, Map<String, Object?> metadata) =>
    flagsmith.trackExposureEvent(
      feature,
      user: Identity(identifier: identifier),
      value: value,
      metadata: metadata,
    );

List<Map<String, Object?>> asSpecFlags(List<Flag> flags) => [
      for (final flag in flags)
        {
          'feature': flag.feature.name,
          'enabled': flag.enabled,
          'value': flag.value,
        },
    ];
