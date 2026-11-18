import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/features/auth/domain/entities/app_user.dart';

/// The user's photo (e.g. from Google), or their initials when there is
/// none (email accounts). A guest ([user] is `null`) gets a person icon.
class UserAvatar extends StatelessWidget {
  const UserAvatar({required this.user, this.radius = 44, super.key});

  final AppUser? user;
  final double radius;

  /// Up to two letters: "Lamees Saad" -> "LS", "lamees@x.com" -> "L".
  static String initialsOf(AppUser user) {
    final name = user.displayName?.trim() ?? '';
    final source = name.isNotEmpty ? name : (user.email ?? '');
    final words = source.split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
    if (words.isEmpty) return '?';
    // An email is one "word": only its first letter is used.
    final letters = name.isNotEmpty
        ? words.take(2).map((word) => word.characters.first)
        : [words.first.characters.first];
    return letters.join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final user = this.user;
    final photoUrl = user?.photoUrl;
    return CircleAvatar(
      radius: radius,
      // A soft tint from the theme, so it fits light and dark mode.
      backgroundColor: colors.primaryContainer,
      foregroundColor: colors.onPrimaryContainer,
      // The initials stay underneath while the photo loads (or if it fails).
      foregroundImage: photoUrl == null
          ? null
          : CachedNetworkImageProvider(photoUrl),
      child: user == null
          ? Icon(Icons.person_outline, size: radius)
          : Text(
              initialsOf(user),
              style: TextStyle(
                fontSize: radius * 0.7,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}
