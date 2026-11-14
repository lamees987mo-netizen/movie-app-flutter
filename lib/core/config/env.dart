/// Compile-time configuration passed with `--dart-define` or
/// `--dart-define-from-file=env.json`.
abstract final class Env {
  /// TMDB "API Read Access Token" (v4). Never commit the real value.
  static const String tmdbToken = String.fromEnvironment('TMDB_TOKEN');

  /// Fails fast when the token was not provided, in every build mode (an
  /// `assert` would be removed from release builds, and the app would then
  /// only show confusing "server" errors).
  static void ensureConfigured() {
    if (tmdbToken.isEmpty) {
      throw StateError(
        'TMDB_TOKEN is missing. Copy env.example.json to env.json, paste your '
        'TMDB read access token, then run: '
        'flutter run --dart-define-from-file=env.json',
      );
    }
  }
}
