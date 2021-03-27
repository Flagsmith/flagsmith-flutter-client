/// Custom exception type
///
/// [notSaved] - store could't save item
/// [notFound] - store could't found item
/// [notDeleted] - store could't delete item
/// [connectionSettings] - internet connection issues
/// [wrongFlagFormat] - flag/feature json format error
/// [genericError] - unknown error
/// [cachesDisabled] - enable cache in FlagsmithConfig

enum FlagsmithExceptionType {
  // store could't save item
  notSaved,
  // store could't found item
  notFound,
  // store could't delete item
  notDeleted,
  // internet connection issues
  connectionSettings,
  // flag/feature json format error
  wrongFlagFormat,
  // unknown error
  genericError,
  // trying to use query on caches without caches
  cachesDisabled
}

class FlagsmithException implements Exception {
  FlagsmithExceptionType type;
  FlagsmithException(this.type);
}
