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
    final isArabic = _languageCode() == 'ar';
    // `putIfAbsent`: a request that sets its own values keeps them.
    options.queryParameters
      ..putIfAbsent('language', () => isArabic ? 'ar' : 'en-US')
      // Without this, TMDB returns only videos in `language`, and almost no
      // movie has an Arabic trailer, so the Arabic app showed no "Play
      // trailer" button. Fall back to English (and language-less) videos.
      ..putIfAbsent(
        'include_video_language',
        () => isArabic ? 'ar,en,null' : 'en,null',
      );
    handler.next(options);
  }
}
