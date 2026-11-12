import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_app/core/network/interceptors/language_interceptor.dart';

class _MockHandler extends Mock implements RequestInterceptorHandler {}

void main() {
  setUpAll(() => registerFallbackValue(RequestOptions()));

  /// Runs [interceptor] on a fresh request and returns its query parameters.
  Map<String, dynamic> run(
    LanguageInterceptor interceptor, {
    Map<String, dynamic>? query,
  }) {
    final handler = _MockHandler();
    final options = RequestOptions(path: '/movie/1', queryParameters: query);
    interceptor.onRequest(options, handler);
    verify(() => handler.next(options)).called(1);
    return options.queryParameters;
  }

  test('adds language=ar when the app is in Arabic', () {
    expect(run(LanguageInterceptor(() => 'ar'))['language'], 'ar');
  });

  test('adds language=en-US when the app is in English', () {
    expect(run(LanguageInterceptor(() => 'en'))['language'], 'en-US');
  });

  test('reads the current language on every request', () {
    var code = 'en';
    final interceptor = LanguageInterceptor(() => code);

    expect(run(interceptor)['language'], 'en-US');
    code = 'ar';
    expect(run(interceptor)['language'], 'ar');
  });

  test('keeps a language the request already set', () {
    final query = run(
      LanguageInterceptor(() => 'ar'),
      query: {'language': 'fr'},
    );
    expect(query['language'], 'fr');
  });
}
