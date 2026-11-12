import 'package:dio/dio.dart';

/// Adds the TMDB read access token to every request.
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._token);

  final String _token;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers['Authorization'] = 'Bearer $_token';
    handler.next(options);
  }
}
