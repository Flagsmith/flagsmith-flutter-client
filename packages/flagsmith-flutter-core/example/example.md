<img width="100%" src="https://github.com/Flagsmith/flagsmith/raw/main/static-files/hero.png"/>

# Core package for Flagsmith Flutter SDK

Internally used in Flagsmith Client for basic store data with models.

```dart
import "package:flagsmith_flutter_core/flagsmith_flutter_core.dart";
```

# Custom storage

You can implement your own storage implementation by extending of `CoreStorage`

```dart
class CustomStorage extends CoreStorage{
    ...
}

final client = FlagsmithClient(
      apiKey: 'your_api_key',
      config: FlagsmithConfig(
          storageType: StorageType.custom, 
          isDebug: true,
        ),
        storage: CustomStorage()
    );
    await client.initialize();
```