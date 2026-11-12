import 'package:flutter_test/flutter_test.dart';
import 'package:movie_app/core/network/image_url.dart';

void main() {
  const path = '/abc.jpg';

  group('build', () {
    test('uses w342 by default', () {
      expect(ImageUrl.build(path), 'https://image.tmdb.org/t/p/w342/abc.jpg');
    });

    test('uses the requested size', () {
      for (final size in ImageSize.values) {
        expect(
          ImageUrl.build(path, size: size),
          'https://image.tmdb.org/t/p/${size.name}/abc.jpg',
        );
      }
    });

    test('returns null when there is no image', () {
      expect(ImageUrl.build(null), isNull);
      expect(ImageUrl.build(''), isNull);
    });
  });

  test('poster uses w342', () {
    expect(ImageUrl.poster(path), 'https://image.tmdb.org/t/p/w342/abc.jpg');
    expect(ImageUrl.poster(null), isNull);
  });

  test('backdrop uses w780', () {
    expect(ImageUrl.backdrop(path), 'https://image.tmdb.org/t/p/w780/abc.jpg');
    expect(ImageUrl.backdrop(null), isNull);
  });

  test('profile uses w185', () {
    expect(ImageUrl.profile(path), 'https://image.tmdb.org/t/p/w185/abc.jpg');
    expect(ImageUrl.profile(''), isNull);
  });
}
