/// Exceptions thrown by the data layer (data sources).
///
/// Repositories catch them and turn them into a `Failure`, so nothing above
/// the data layer has to use try/catch.
sealed class AppException implements Exception {
  const AppException();
}

/// The server answered with an error status code (4xx/5xx).
final class ServerException extends AppException {
  const ServerException({this.statusCode, this.message});

  final int? statusCode;
  final String? message;

  @override
  String toString() => 'ServerException($statusCode, $message)';
}

/// No connection, DNS failure or timeout.
final class NetworkException extends AppException {
  const NetworkException();

  @override
  String toString() => 'NetworkException()';
}

/// Reading from or writing to local storage (Hive) failed.
final class CacheException extends AppException {
  const CacheException([this.message]);

  final String? message;

  @override
  String toString() => 'CacheException($message)';
}
