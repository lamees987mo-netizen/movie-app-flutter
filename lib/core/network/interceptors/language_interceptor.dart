import 'package:dio/dio.dart';

/// Adds TMDB's `language` query parameter, so titles, overviews and genres
/// come back in the app's current language.
class LanguageInterceptor extends Interceptor {
  /// The language-code function is called on every request (instead of
  /// passing a fixed value), so a language change applies to the next
  /// request.
  /// It is a plain function so this class does not depend on the settings
  /// feature, and tests can pass `() => 'ar'`.
  LanguageInterceptor(this._languageCode);

  final String Function() _languageCode;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // `putIfAbsent`: a request that sets its own language keeps it.
    options.queryParameters.putIfAbsent(
      'language',
      () => _languageCode() == 'ar' ? 'ar' : 'en-US',
    );
    handler.next(options);
  }
}
