import 'package:dio/dio.dart';

/// Generic FlagsmithException
class FlagsmithException implements Exception {
  final dynamic message;

  FlagsmithException([this.message]);

  @override
  String toString() {
    Object? message = this.message;
    if (message == null) {
      return 'FlagsmithException';
    }
    return 'FlagsmithException: $message';
  }
}

/// FlagsmithFormatException
/// - FormatException wrapper
class FlagsmithFormatException extends FormatException {
  FlagsmithFormatException(FormatException e)
      : super(e.message, e.source, e.offset);
}

/// FlagsmithApiException
/// - DioException / Api error wrapper
class FlagsmithApiException extends DioException {
  FlagsmithApiException(DioException error)
      : super(
          requestOptions: error.requestOptions,
          response: error.response,
          type: error.type,
          error: error.error,
        );
}

/// FlagsmithConfigException
/// - When client is misconfigured
class FlagsmithConfigException extends FlagsmithException {
  FlagsmithConfigException(Exception e) : super(e);
}
