// This file contains the SDK version information
// The version is automatically updated by release-please

/// The SDK version
// x-release-please-start-version
const String sdkVersion = '6.0.3';
// x-release-please-end

/// Gets the User-Agent header value for the SDK
///
/// Format: flagsmith-flutter-sdk/<version>
String getUserAgent() {
  return 'flagsmith-flutter-sdk/$sdkVersion';
}
