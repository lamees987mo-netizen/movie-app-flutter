import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movie_app/core/network/image_url.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/features/movies/domain/entities/movie_details.dart';
import 'package:movie_app/features/person/presentation/navigation/person_args.dart';

/// A horizontal list of actors: photo, name and character. Tapping one
/// opens their page.
class CastList extends StatelessWidget {
  const CastList({required this.cast, super.key});

  final List<CastMember> cast;

  static const double _itemWidth = 88;
  static const double _height = 150;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _height,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.symmetric(
          horizontal: AppSpacing.md,
        ),
        itemCount: cast.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) => SizedBox(
          width: _itemWidth,
          child: _CastTile(member: cast[index]),
        ),
      ),
    );
  }
}

class _CastTile extends StatelessWidget {
  const _CastTile({required this.member});

  final CastMember member;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final photoUrl = ImageUrl.profile(member.profilePath);
    return InkWell(
      borderRadius: BorderRadius.circular(AppSpacing.sm),
      // Name and photo go along, so the person page shows them at once.
      onTap: () => context.pushPerson(
        member.id,
        name: member.name,
        profilePath: member.profilePath,
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundImage: photoUrl == null
                ? null
                : CachedNetworkImageProvider(photoUrl),
            child: photoUrl == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            member.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelLarge,
          ),
          Text(
            member.character,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
