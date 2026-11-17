import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/routes.dart';

/// `context.pushTrailer(key, title: movie.title)` opens the trailer page.
///
/// The `title` travels through go_router's `extra`: it is optional, so a
/// link like `/trailer/<key>` still works (the page then says "Trailer").
extension TrailerNavigation on BuildContext {
  Future<void> pushTrailer(String youtubeKey, {String? title}) =>
      push(TrailerRoutes.pathFor(youtubeKey), extra: title);
}
