import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:movie_app/core/network/api_endpoints.dart';
import 'package:movie_app/core/network/interceptors/auth_interceptor.dart';
import 'package:movie_app/core/network/interceptors/error_interceptor.dart';
import 'package:movie_app/core/network/interceptors/language_interceptor.dart';

/// Creates the single [Dio] instance used for every TMDB request.
///
/// [languageCode] returns the app's current language code (e.g. `ar`).
Dio createDioClient({
  required String token,
  required String Function() languageCode,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(token),
    LanguageInterceptor(languageCode),
    ErrorInterceptor(),
    if (kDebugMode)
      // Headers are not logged so the token never reaches the console.
      LogInterceptor(requestHeader: false),
  ]);

  return dio;
}
