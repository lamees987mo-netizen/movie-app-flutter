/// Compile-time configuration passed with `--dart-define` or
/// `--dart-define-from-file=env.json`.
abstract final class Env {
  /// TMDB "API Read Access Token" (v4). Never commit the real value.
  static const String tmdbToken = String.fromEnvironment('TMDB_TOKEN');

  /// Fails fast in debug builds when the token was not provided.
  static void ensureConfigured() {
    assert(
      tmdbToken.isNotEmpty,
      'TMDB_TOKEN is missing. Copy env.example.json to env.json, paste your '
      'TMDB read access token, then run: '
      'flutter run --dart-define-from-file=env.json',
    );
  }
}
