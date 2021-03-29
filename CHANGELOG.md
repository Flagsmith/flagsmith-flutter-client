## [2.0.0-nullsafety.0] - 03/27/2021
* init version of nullsafety version
## [1.0.1] - 03/27/2021
* minor update
## [1.0.0-prev.0] - 03/27/2021
*Bullet train client* is **Flagsmith**
* rebranding to ***Flagsmith***
* `isDebug` logs exceptions to console with prefix *Flagsmith:*.

**Client**
* adding `client.loading` stream [loading] [loaded] for detection api request state
* adding `FlagsmithClient({ bool update = false})` for update from api directly after init
* adding async init `FlagsmithClient.init({FlagsmithConfig config = const FlagsmithConfig(),@required String apiKey,List<Flag> seeds,bool update = false})`
* adding `Flag.seed(String featureName, {bool enabled, String value})`

**Config**
* adding `caches` with default value `false`
* adding caches to client and new `bool hasCachedFeatureFlag(String featureName, {FeatureUser user})`
## [0.1.5] - 11/26/2020

- fix getFeatureFlagValue

## [0.1.4] - 10/26/2020

- replace imports for using models in integration tests
## [0.1.3] - 10/21/2020

- fixing seed function
- extending default values for timeouts

## [0.1.2] - 010/04/2020

- adding new attr to config isSelfSigned for overriding self signed cert issues

## [0.1.1] - 09/24/2020

- adding support for streams from storage
- breaking change in storing values
- implementing equatable
- config: new isDebug attr for toggle loging to console

## [0.1.0+2] - 09/22/2020

- rxdart range

## [0.1.0+1] - 09/21/2020

- minor fixes

## [0.1.0] - 09/21/2020

- securing sotrages
- change persistant storage
- changing config attributes for storage
- minor fixes

## [0.0.4+3] - 09/15/2020

- added missing initial value field in Feature

## [0.0.4+2] - 09/12/2020

- dependency package

## [0.0.4+1] - 09/12/2020

- path as parameter in Persistent storage

## [0.0.4+0] - 09/12/2020

- removed freezed from library
- removed dio logging interceptor
- removed builder
- fixing persistent storage
- full page example

## [0.0.3+1] - 09/11/2020

- switch to pedantic

## [0.0.3] - 09/11/2020

- Reading from InMemoryStorage
- Added persistante storage
- Handling errors with custom Exception
- fixing freezed issue

## [0.0.2+6] - 09/10/2020

- Reading from InMemoryStorage
- Added persistent storage
- Handling errors with custom Exception
- fixing freezed issue

## [0.0.2+5] - 09/08/2020

- Fixing readme

## [0.0.2+4] - 09/08/2020

- Fixing dartfm

## [0.0.2+3] - 09/08/2020

- Fixing control_flow_in_finally

## [0.0.2+2] - 09/08/2020

- Fixing flutter web support

## [0.0.2+1] - 09/08/2020

- Updated readme

## [0.0.2] - 09/08/2020

- Added unit tests
- Fixed user and traits

## [0.0.1] - 09/07/2020

- TODO: Describe initial release.
