import 'dart:io';

import 'package:dio/dio.dart';
import 'package:movie_app/core/error/exceptions.dart';

/// Translates Dio errors into the app's own [AppException] types.
///
/// The typed exception is stored in [DioException.error], so data sources
/// only need to unwrap it and never deal with Dio error types themselves.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    handler.next(err.copyWith(error: _toAppException(err)));
  }

  AppException _toAppException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        // Every bad status stays a ServerException with its code, also 401
        // (bad token): the app cannot fix a token at runtime, so it needs
        // no special failure type; the code is kept for logs and tests.
        return ServerException(
          statusCode: err.response?.statusCode,
          message: _statusMessage(err.response?.data),
        );
      case DioExceptionType.badCertificate:
      case DioExceptionType.cancel:
      case DioExceptionType.transformTimeout:
      case DioExceptionType.unknown:
        // `IOException` covers more than `SocketException`: e.g. an
        // `HttpException` when the connection drops mid-response, or a
        // `TlsException` behind a captive portal. All of them mean "the
        // network failed", not "the server answered with an error".
        if (err.error is IOException) return const NetworkException();
        return ServerException(statusCode: err.response?.statusCode);
    }
  }

  /// TMDB puts a human readable reason in `status_message`.
  String? _statusMessage(Object? data) {
    if (data is Map<String, dynamic>) return data['status_message'] as String?;
    return null;
  }
}
