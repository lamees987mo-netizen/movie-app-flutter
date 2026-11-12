/// Image widths supported by the TMDB image CDN that this app uses.
enum ImageSize { w185, w342, w500, w780, original }

/// Builds full TMDB image URLs from the relative paths in API responses.
abstract final class ImageUrl {
  static const String _baseUrl = 'https://image.tmdb.org/t/p/';

  /// Returns `null` when the movie has no image, so the UI can show a
  /// placeholder instead of a broken URL.
  static String? build(String? path, {ImageSize size = ImageSize.w342}) {
    if (path == null || path.isEmpty) return null;
    return '$_baseUrl${size.name}$path';
  }

  static String? poster(String? path) => build(path);

  static String? backdrop(String? path) => build(path, size: ImageSize.w780);

  static String? profile(String? path) => build(path, size: ImageSize.w185);
}
