# Changelog

## [6.0.3](https://github.com/Flagsmith/flagsmith-flutter-client/compare/v6.0.2...v6.0.3) (2025-07-08)


### Bug Fixes

* Prevent dio warning logs on Web

## [6.0.2](https://github.com/Flagsmith/flagsmith-flutter-client/compare/v6.0.1...v6.0.2) (2025-07-07)


### CI

* add release please configuration ([#75](https://github.com/Flagsmith/flagsmith-flutter-client/issues/75)) ([6583788](https://github.com/Flagsmith/flagsmith-flutter-client/commit/6583788bb649c424f213ffefe0ab3256e687dc5e))

## [6.0.1]

- Fix custom storage

## [6.0.0]

Breaking Changes:

- Drop Flutter 2 support

Features:

- Support transient identities and traits

Other:

- Integrate `flagsmith_core` and `flagsmith_storage_sharedpreferences`
- Minor unit test improvements

## [5.0.1]

- Change the base url to https://edge.api.flagsmith.com/api/v1/


## [5.0.0]

- Realtime flags

## [4.0.0]

- trait/value: Add support for int,float, bool and string
- Upgrade [flagsmith_core](https://pub.dev/packages/flagsmith_core)

## [3.1.0]

- Upgrade dio
- Github Workflows improvements

## [3.0.3]

- Upgrade rxdart dependency

## [3.0.2]

- Only call analytics if there are feature evaluations to track

## [3.0.1]

- Expose `reload` option on all methods for retrieving flag information for a user
- Fix `updateTraits` method following move to edge (which deprecated `/traits/bulk/` endpoint)

## [3.0.0]

- Update default URL to Edge API.

## [2.3.0]

- Refactor to rely on https://github.com/Flagsmith/flagsmith-flutter-core

## [2.2.0-beta.1]- 17/10/2021

Features:

- new function **getCachedFeatureFlagValue**
- adding analytics test, refac. of api request

Fixes:

- cancel timer on close
- reloading of caches

## [2.2.0-beta.0]- 13/10/2021

Features:

- [Flag Analytics](https://docs.flagsmith.com/advanced-use/flag-analytics)

## [2.1.0-alpha.0]- 24/09/2021

Fixes:

- adding support for flutter web with pana score

### Breaking Changes

- storage was moved to the separate package
- [flagsmith_core](https://pub.dev/packages/flagsmith_core) is a new package with models and storage implementation
- persistent storage is available as custom package
  [flagsmith_storage_sharedpreferences](https://pub.dev/packages/flagsmith_storage_sharedpreferences)

## [2.0.1+2]- 20/08/2021

Fixes:

- removing isolate

## [2.0.1+1]- 20/08/2021

Fixes:

- adding support for flutter web

## [2.0.1]- 09/08/2021

Breaking Changes:

- removing async update from constructor (anti-pattern)
- removing FlagsmithException(type) and replacing with
- FlagsmithApiException
- FlagsmithConfigException
- FlagsmithFormatException
- FlagsmithException

Features:

- response conversion in isolate
- adding json_serializable dependency
- support for

### Fixes

- fixing InMemoryStorage return values instead of exceptions
- fixing update caches
- fixing name conversion
- adding missing tests

## [2.0.0]- 06/20/2021

- first official null-safety release of Flagsmith SDK for Flutter
- expose Dio client `FlagsmithClient.client`

## [2.0.0-nullsafety.1]- 06/17/2021

- remove reliance on `type` attribute of feature
- minor fixes to example app
- FeatureUser replaced by Identity model
- new Trait function for create / bulk
- fixing example app

## [2.0.0-nullsafety.0]- 03/27/2021

- init version of nullsafety version

## [1.1.0]- 14/04/2021

- remove reliance on type attribute of feature
- minor fixes to example app

## [1.0.1]- 03/27/2021

- minor update

## [1.0.0-prev.0]- 03/27/2021

_Bullet train client_ is **Flagsmith**

- rebranding to **_Flagsmith_**
- `isDebug` logs exceptions to console with prefix _Flagsmith:_.

Client:

- adding `client.loading` stream [loading] [loaded] for detection api request state
- adding `FlagsmithClient({ bool update = false})` for update from api directly after init
- adding async init
  `FlagsmithClient.init({FlagsmithConfig config = const FlagsmithConfig(),@required String apiKey,List<Flag> seeds,bool update = false})`
- adding `Flag.seed(String featureName, {bool enabled, String value})`

Config:

- adding `caches` with default value `false`
- adding caches to client and new `bool hasCachedFeatureFlag(String featureName, {FeatureUser user})`

## [0.1.5]- 11/26/2020

- fix getFeatureFlagValue

## [0.1.4]- 10/26/2020

- replace imports for using models in integration tests

## [0.1.3]- 10/21/2020

- fixing seed function
- extending default values for timeouts

## [0.1.2]- 010/04/2020

- adding new attr to config `isSelfSigned` for overriding self-signed cert issues

## [0.1.1]- 09/24/2020

- adding support for streams from storage
- breaking change in storing values
- implementing equatable
- config: new isDebug attr for toggle logging to console

## [0.1.0+2]- 09/22/2020

- rxdart range

## [0.1.0+1]- 09/21/2020

- minor fixes

## [0.1.0]- 09/21/2020

- securing storages
- change persistent storage
- changing config attributes for storage
- minor fixes

## [0.0.4+3]- 09/15/2020

- added missing initial value field in Feature

## [0.0.4+2]- 09/12/2020

- dependency package

## [0.0.4+1]- 09/12/2020

- path as a parameter in Persistent storage

## [0.0.4+0]- 09/12/2020

- removed freezed from library
- removed dio logging interceptor
- removed builder
- fixing persistent storage
- full page example

## [0.0.3+1]- 09/11/2020

- switch to pedantic

## [0.0.3]- 09/11/2020

- Reading from InMemoryStorage
- Added persistent storage
- Handling errors with custom Exception
- fixing freezed issue

## [0.0.2+6]- 09/10/2020

- Reading from InMemoryStorage
- Added persistent storage
- Handling errors with custom Exception
- fixing freezed issue

## [0.0.2+5]- 09/08/2020

- Fixing readme

## [0.0.2+4]- 09/08/2020

- Fixing dartfm

## [0.0.2+3]- 09/08/2020

- Fixing control_flow_in_finally

## [0.0.2+2]- 09/08/2020

- Fixing flutter web support

## [0.0.2+1]- 09/08/2020

- Updated readme

## [0.0.2]- 09/08/2020

- Added unit tests
- Fixed user and traits

## [0.0.1]- 09/07/2020

- TODO: Describe the initial release.
