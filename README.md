<img width="100%" src="https://github.com/Flagsmith/flagsmith/raw/main/static-files/hero.png"/>

# Flagsmith Flutter SDK

Flagsmith allows you to manage feature flags and remote config across multiple projects, environments and organisations.

This is the SDK for Flutter for [https://www.flagsmith.com/](https://www.flagsmith.com/).

## Adding to your project

For full documentation visit [https://docs.flagsmith.com/clients/flutter/](https://docs.flagsmith.com/clients/flutter/)

## Experiments

Once an experiment is running, Flagsmith serves the variations automatically through the flag. Your application
records exposures (when an identity experienced a variation) and conversion events (what your metrics aggregate).

Enable event collection with `enableEvents`. Users must be identified: exposures and conversion events are joined per
identity, so use the same identifier for flags and events.

```dart
final flagsmith = await FlagsmithClient.init(
  apiKey: 'YOUR_CLIENT_SIDE_ENVIRONMENT_KEY',
  config: const FlagsmithConfig(enableEvents: true),
);
final user = Identity(identifier: 'user_42');
await flagsmith.getFeatureFlags(user: user);

// Evaluate the flag and record an exposure in one call
final flag = await flagsmith.getExperimentFlag('checkout_button', user: user);
// ...render based on flag?.variant / flag?.stateValue

// Record a conversion event; the name must match your metric's event name
flagsmith.trackEvent('purchase', value: 99.5);
```

### Exposures

`getExperimentFlag` evaluates the flag and records a `$flag_exposure` event with the served `variant` as its value. It
is only recorded when the flag exists, is enabled and the identity is enrolled (`flag.experiment?.inExperiment == true`).
Anything else is logged and skipped, so it is safe to call against environments or servers without experiments.

If you evaluate in one place and render in another, call `trackExposureEvent` at the point of display instead:

```dart
flagsmith.trackExposureEvent('checkout_button', value: flag.variant,
    metadata: {'experiment_id': flag.experiment!.id});
```

Exposures are deduplicated per identity and variant within a flush window, so recording one more than once is safe.

### Conversion events

`trackEvent` sends a named event, optionally with a `value`, `traits` and `metadata`. Names starting with `$` are
reserved. The event name is case-sensitive and must match the metric's configured event name.

### Flushing

Events are buffered and posted to `eventsURI` every `eventsFlushInterval` ms (10 s) or when `eventsMaxBuffer` (1000)
events are queued. `close()` flushes best-effort; await `flushEvents()` when you need the POST to complete, e.g. before
the app is torn down. Network failures are retried once, then logged and dropped; they never throw.

## Contributing

Please read [CONTRIBUTING.md](https://gist.github.com/kyle-ssg/c36a03aebe492e45cbd3eefb21cb0486) for details on our code of conduct, and the process for submitting pull requests to us.

## Getting Help

If you encounter a bug or feature request we would like to hear about it. Before you submit an issue please search existing issues in order to prevent duplicates.

## Get in touch

If you have any questions about our projects you can email <a href="mailto:support@flagsmith.com">support@flagsmith.com</a>.
