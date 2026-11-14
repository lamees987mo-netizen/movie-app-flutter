import 'package:flutter/material.dart';
import 'package:movie_app/core/network/image_url.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/features/movies/presentation/widgets/network_image_or_placeholder.dart';
import 'package:movie_app/features/person/domain/entities/person.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Photo, name, birthday and place of birth, side by side.
class PersonHeader extends StatelessWidget {
  const PersonHeader({required this.person, super.key});

  final Person person;

  static const double _photoWidth = 110;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final birthday = person.birthday;
    final placeOfBirth = person.placeOfBirth;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Keep the real photo while loading: it usually comes from the
        // cast list (PersonArgs), so it can be shown at once.
        Skeleton.keep(
          child: SizedBox(
            width: _photoWidth,
            child: Card(
              margin: EdgeInsets.zero,
              child: AspectRatio(
                aspectRatio: 2 / 3,
                child: NetworkImageOrPlaceholder(
                  url: ImageUrl.profile(person.profilePath),
                  icon: Icons.person,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(person.name, style: theme.textTheme.headlineSmall),
              if (birthday != null)
                _InfoItem(
                  icon: Icons.cake_outlined,
                  text: l10n.personBorn(
                    MaterialLocalizations.of(context).formatFullDate(birthday),
                  ),
                ),
              if (placeOfBirth != null)
                _InfoItem(
                  icon: Icons.place_outlined,
                  text: placeOfBirth,
                  semanticsLabel: '${l10n.personPlaceOfBirth}: $placeOfBirth',
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.icon,
    required this.text,
    this.semanticsLabel,
  });

  final IconData icon;
  final String text;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsetsDirectional.only(top: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: colors.primary),
          const SizedBox(width: AppSpacing.xs),
          Flexible(child: Text(text, semanticsLabel: semanticsLabel)),
        ],
      ),
    );
  }
}
