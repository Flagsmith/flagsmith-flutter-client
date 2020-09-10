enum BulletTrainExceptionType {
  notSaved,
  notFound,
  notDeleted,
  connectionSettings,
  wrongFlagFormat,
  genericError
}

class BulletTrainException implements Exception {
  BulletTrainExceptionType type;
  BulletTrainException(this.type);
}
