import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/error/exceptions.dart';
import 'package:movie_app/core/network/interceptors/error_interceptor.dart';

class _MockHandler extends Mock implements ErrorInterceptorHandler {}

void main() {
  final requestOptions = RequestOptions(path: 'movie/1');

  setUpAll(() {
    registerFallbackValue(DioException(requestOptions: requestOptions));
    registerFallbackValue(Response<dynamic>(requestOptions: requestOptions));
  });

  /// Runs the interceptor on [err] and returns the error it passed on.
  DioException run(DioException err) {
    final handler = _MockHandler();
    ErrorInterceptor().onError(err, handler);

    final passed =
        verify(() => handler.next(captureAny())).captured.single
            as DioException;
    verifyNever(() => handler.reject(any()));
    verifyNever(() => handler.resolve(any()));
    return passed;
  }

  DioException error(
    DioExceptionType type, {
    Response<dynamic>? response,
    Object? cause,
  }) => DioException(
    requestOptions: requestOptions,
    type: type,
    response: response,
    error: cause,
  );

  Response<dynamic> response(int statusCode, [Object? data]) =>
      Response<dynamic>(
        requestOptions: requestOptions,
        statusCode: statusCode,
        data: data,
      );

  group('becomes a NetworkException for', () {
    for (final type in [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ]) {
      test(type.name, () {
        expect(run(error(type)).error, isA<NetworkException>());
      });
    }

    for (final type in [
      DioExceptionType.badCertificate,
      DioExceptionType.cancel,
      DioExceptionType.transformTimeout,
      DioExceptionType.unknown,
    ]) {
      test('${type.name} caused by a SocketException', () {
        final err = error(type, cause: const SocketException('no route'));
        expect(run(err).error, isA<NetworkException>());
      });
    }

    for (final cause in [
      const HttpException('Connection closed while receiving data'),
      const TlsException('handshake failed'),
      const FileSystemException('cannot write'),
    ]) {
      test('unknown caused by ${cause.runtimeType} (an IOException)', () {
        final err = error(DioExceptionType.unknown, cause: cause);
        expect(run(err).error, isA<NetworkException>());
      });
    }
  });

  group('badResponse becomes a ServerException', () {
    test('with the status code and the TMDB status_message', () {
      final err = error(
        DioExceptionType.badResponse,
        response: response(401, {
          'status_code': 7,
          'status_message': 'Invalid API key.',
        }),
      );

      final appError = run(err).error;
      expect(
        appError,
        isA<ServerException>()
            .having((e) => e.statusCode, 'statusCode', 401)
            .having((e) => e.message, 'message', 'Invalid API key.'),
      );
    });

    test('without a message when the body is not a JSON map', () {
      final err = error(
        DioExceptionType.badResponse,
        response: response(502, '<html>Bad Gateway</html>'),
      );

      expect(
        run(err).error,
        isA<ServerException>()
            .having((e) => e.statusCode, 'statusCode', 502)
            .having((e) => e.message, 'message', isNull),
      );
    });

    test('without a status code when there is no response', () {
      expect(
        run(error(DioExceptionType.badResponse)).error,
        isA<ServerException>()
            .having((e) => e.statusCode, 'statusCode', isNull)
            .having((e) => e.message, 'message', isNull),
      );
    });
  });

  group('becomes a ServerException (no IOException) for', () {
    for (final type in [
      DioExceptionType.badCertificate,
      DioExceptionType.cancel,
      DioExceptionType.transformTimeout,
      DioExceptionType.unknown,
    ]) {
      test(type.name, () {
        final err = error(
          type,
          response: response(500),
          cause: const FormatException('bad'),
        );
        expect(
          run(err).error,
          isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 500)
              .having((e) => e.message, 'message', isNull),
        );
      });
    }
  });

  test('keeps the rest of the DioException unchanged', () {
    final original = error(
      DioExceptionType.badResponse,
      response: response(404),
    );

    final passed = run(original);

    expect(passed.type, DioExceptionType.badResponse);
    expect(passed.requestOptions, same(requestOptions));
    expect(passed.response?.statusCode, 404);
  });
}
