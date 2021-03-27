<img width="100%" src="https://raw.githubusercontent.com/SolidStateGroup/bullet-train-frontend/master/hero.png"/>

# Flagsmith SDK for Flutter

> Flagsmith allows you to manage feature flags and remote config across multiple projects, environments and organisations.

The SDK for Flutter applications for [https://flagsmith.com/](https://flagsmith.com/).

## Getting Started

The client library is available from the [https://pub.dev](https://pub.dev/packages/flagsmith):

```dart
dependencies:
  flagsmith: <latest>
```

## Usage

### Retrieving feature flags for your project

**For full documentation visit [https://docs.flagsmith.com/](https://docs.flagsmith.com/)**

Sign Up and create an account at [https://flagsmith.com/](https://flagsmith.com/)

In your application, initialise the BulletTrain client with your API key:

```dart
var flagsmithClient = FlagsmithClient(apiKey: 'YOUR_ENV_API_KEY')
```

To check if a feature flag exists and is enabled:

```dart
bool featureEnabled = await flagsmithClient.hasFeatureFlag("my_test_feature");
if (featureEnabled) {
    // run the code to execute enabled feature
} else {
    // run the code if feature switched off
}
```

To get the configuration value for a feature flag:

```dart
var myRemoteConfig = await flagsmithClient.getFeatureFlagValue("my_test_feature");
if (myRemoteConfig != null) {
    // run the code to use remote config value
} else {
    // run the code without remote config
}
```

### Identifying users

Identifying users allows you to target specific users from the [Flagsmith dashboard](https://flagsmith.com/).

To check if a feature exists for a given user Identity:

```dart
var user = FeatureUser(identifier: 'flagsmith_sample_user');
bool featureEnabled = await flagsmithClient.hasFeatureFlag('my_test_feature', user: user);
if (featureEnabled) {
    // run the code to execute enabled feature for given user
} else {
    // run the code when feature switched off
}
```

To get the configuration value for a feature flag for given a user Identity:

```dart
var myRemoteConfig = await flagsmithClient.getFeatureFlagValue('my_test_feature', user: user);
if (myRemoteConfig != null) {
    // run the code to use remote config value
} else {
    // run the code without remote config
}
```

To get the user traits for given user Identity:

```dart
var userTraits = await flagsmithClient.getTraits(user)
if (userTraits != null && userTraits) {
    // run the code to use user traits
} else {
    // run the code without user traits
}
```

To get user trait for given user Identity and specific Trait key:

```dart
var userTrait = await flagsmithClient.getTrait(user, 'cookies_key');
if (userTrait != null) {
    // run the code to use user trait
} else {
    // run the code without user trait
}
```

Or get user traits for given user Identity and specific Trait keys:

```dart
 var userTraits = await flagsmithClient.getTraits(user, keys: ['cookies_key', 'other_trait']);
if (userTraits != null) {
    // run the code to use user traits
} else {
    // run the code without user traits
}
```

To update a user trait for given user Identity:

```dart
 var userTrait = await flagsmithClient.getTrait(user, 'cookies_key');
if (userTrait != null) {
    // update value for user trait
    var updatedTrait = userTrait.copyWith(value: 'new value');
    Trait updated = await flagsmithClient.updateTrait(user, updatedTrait);
} else {
    // run the code without user trait
}
```

## Override default configuration

By default, the client uses the default configuration. You can override this configuration as follows:

```dart
var flagsmithClient = FlagsmithClient(
      config: FlagsmithConfig(
          baseURI: 'http://yoururl.com/'
      ), apiKey: 'YOUR_ENV_API_KEY');
```

Override the default configuration with your own:

```dart
final appDir = await getApplicationDocumentsDirectory();
await appDir.create(recursive: true);
final databasePath = join(appDir.path, 'flagsmith.db');

var flagsmithClient = FlagsmithClient(
      config: FlagsmithConfig(
          baseURI: 'http://yoururl.com/',
          connectTimeout: 200,
          receiveTimeout: 500,
          sendTimeout: 500,
          usePersitantStorage: true,
          persistantDatabasePath: databasePath,
      ), apiKey: 'YOUR_ENV_API_KEY');
```

## Getting Help

If you encounter a bug or feature request we would like to hear about it. Before you submit an issue please search existing issues in order to prevent duplicates.

## Get in touch

If you have any questions about our projects you can email [printeastwoodcz@gmail.com](mailto:printeastwoodcz@gmail.com).
