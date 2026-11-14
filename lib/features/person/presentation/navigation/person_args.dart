import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:movie_app/core/router/routes.dart';

/// Optional data handed to the person route through go_router's `extra`,
/// like `MovieDetailsArgs`.
///
/// We already know the name and photo from the cast list, so the header
/// can show them at once while the rest loads. Both are `null` for a deep
/// link, and the page must still work then.
class PersonArgs {
  const PersonArgs({this.name, this.profilePath});

  final String? name;
  final String? profilePath;
}

/// `context.pushPerson(id, name: ..., profilePath: ...)` opens the page.
extension PersonNavigation on BuildContext {
  Future<void> pushPerson(int personId, {String? name, String? profilePath}) =>
      push(
        Routes.personPath(personId),
        extra: PersonArgs(name: name, profilePath: profilePath),
      );
}
