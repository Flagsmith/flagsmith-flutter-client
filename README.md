<img width="100%" src="https://raw.githubusercontent.com/SolidStateGroup/bullet-train-frontend/master/hero.png"/>

# Bullet Train SDK for Flutter

> Bullet Train allows you to manage feature flags and remote config across multiple projects, environments and organisations.

The SDK for Flutter applications for [https://bullet-train.io/](https://bullet-train.io/).

## Getting Started

## Quick Setup

The client library is available from the [https://pub.dev](https://pub.dev) 

```dart
dependencies:
  bullet_train: ^0.0.1
```

## Usage
**Retrieving feature flags for your project**

**For full documentation visit [https://docs.bullet-train.io](https://docs.bullet-train.io)**

Sign Up and create account at [https://bullet-train.io/](https://www.bullet-train.io/)

In your application initialise BulletTrain client with your API key

```dart
var bulletClient = BulletTrainClient(apiKey: 'YOUR_ENV_API_KEY')
```

To check if feature flag exist and enabled:

```dart
bool featureEnabled = bulletClient.hasFeatureFlag("my_test_feature");
if (featureEnabled) {
    // run the code to execute enabled feature
} else {
    // run the code if feature switched off
}
```

To get configuration value for feature flag:

```dart
var myRemoteConfig = bulletClient.getFeatureFlagValue("my_test_feature");
if (myRemoteConfig != null) {    
    // run the code to use remote config value
} else {
    // run the code without remote config
}
```

**Identifying users**

Identifying users allows you to target specific users from the [Bullet Train dashboard](https://www.bullet-train.io/).

To check if feature exist for given user context:

```dart
var user = FeatureUser(identifier: 'bullet_train_sample_user');
boolean featureEnabled = bulletClient.hasFeatureFlag('my_test_feature', user);
if (featureEnabled) {
    // run the code to execute enabled feature for given user
} else {
    // run the code when feature switched off
}
```

To get configuration value for feature flag for given user context:

```dart
var myRemoteConfig = bulletClient.getFeatureFlagValue('my_test_feature', user);
if (myRemoteConfig != null) {    
    // run the code to use remote config value
} else {
    // run the code without remote config
}
```

To get user traits for given user context:

```dart
List<Trait> userTraits = bulletClient.getTraits(user)
if (userTraits != null && userTraits) {    
    // run the code to use user traits
} else {
    // run the code without user traits
}
```

To get user trait for given user context and specific key:

```dart
var userTrait = bulletClient.getTrait(user, 'cookies_key');
if (userTrait != null) {    
    // run the code to use user trait
} else {
    // run the code without user trait
}
```

Or get user traits for given user context and specific keys:

```dart
 var userTraits = bulletClient.getTraits(user, 'cookies_key', 'other_trait');
if (userTraits != null) {    
    // run the code to use user traits
} else {
    // run the code without user traits
}
```

To update value for user traits for given user context and specific keys:

```dart
 var userTrait = bulletClient.getTrait(user, 'cookies_key');
if (userTrait != null) {    
    // update value for user trait
    userTrait.value = "new value";
    Trait updated = bulletClient.updateTrait(user, userTrait);
} else {
    // run the code without user trait
}
```

## Override default configuration

By default, client is using default configuration. You can override configuration as follows:

override just API uri with your own one
```dart
var bulletClient = BulletTrainClient(
      config: BulletTrainConfig(
          baseURI: 'http://yoururl.com/'
      ), apiKey: 'YOUR_ENV_API_KEY');
```

override full configuration with your own
```dart
var bulletClient = BulletTrainClient(
      config: BulletTrainConfig(
          baseURI: 'http://yoururl.com/',
          connectTimeout: 200,
          receiveTimeout: 500,
          sendTimeout: 500,
      ), apiKey: 'YOUR_ENV_API_KEY');
```

## Getting Help

If you encounter a bug or feature request we would like to hear about it. Before you submit an issue please search existing issues in order to prevent duplicates. 

## Get in touch

If you have any questions about our projects you can email <a href="mailto:printeastwoodcz@gmail.com">printeastwoodcz@gmail.com</a>.


