import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/error/failure_message.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/error_view.dart';
import 'package:movie_app/core/widgets/movie_poster_card.dart';
import 'package:movie_app/features/movies/domain/entities/movie.dart';
import 'package:movie_app/features/movies/presentation/navigation/movie_details_args.dart';
import 'package:movie_app/features/person/domain/entities/person.dart';
import 'package:movie_app/features/person/presentation/cubit/person_cubit.dart';
import 'package:movie_app/features/person/presentation/navigation/person_args.dart';
import 'package:movie_app/features/person/presentation/widgets/expandable_text.dart';
import 'package:movie_app/features/person/presentation/widgets/person_header.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// The page of one actor: photo, biography and their movies.
///
/// Like `MovieDetailsPage`, this widget only creates the cubit and
/// [PersonView] draws the screen, so tests can give it a mock cubit.
class PersonPage extends StatelessWidget {
  const PersonPage({
    required this.personId,
    this.preview = const PersonArgs(),
    super.key,
  });

  final int personId;

  /// Name and photo from the cast list, shown while loading.
  final PersonArgs preview;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final cubit = sl<PersonCubit>(param1: personId);
        // Not awaited on purpose: the cubit emits its states as it goes.
        unawaited(cubit.load());
        return cubit;
      },
      child: PersonView(preview: preview),
    );
  }
}

/// Draws the person screen for the state of the [PersonCubit] above it.
class PersonView extends StatelessWidget {
  const PersonView({this.preview = const PersonArgs(), super.key});

  final PersonArgs preview;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PersonCubit, PersonState>(
      builder: (context, state) => switch (state) {
        PersonLoading() => _PersonScaffold(
          person: _skeletonPerson(preview),
          isLoading: true,
        ),
        PersonLoaded(:final person) => _PersonScaffold(person: person),
        PersonError(:final failure) => Scaffold(
          appBar: AppBar(),
          body: ErrorView(
            message: failure.message(AppLocalizations.of(context)),
            onRetry: () => context.read<PersonCubit>().load(),
          ),
        ),
      },
    );
  }

  /// Fake data that only gives the loading skeleton its shape. The real
  /// name and photo are used when we already have them.
  static Person _skeletonPerson(PersonArgs preview) => Person(
    id: 0,
    name: preview.name ?? 'Person name',
    profilePath: preview.profilePath,
    biography: 'A placeholder biography that is long enough. ' * 6,
    birthday: DateTime(2000),
    placeOfBirth: 'Place of birth',
    // Negative ids so they never clash with a real movie.
    knownFor: List.generate(
      6,
      (index) => Movie(id: -1 - index, title: '', overview: '', voteAverage: 0),
    ),
  );
}

/// The same layout for "loading" (as a skeleton) and "loaded".
class _PersonScaffold extends StatelessWidget {
  const _PersonScaffold({required this.person, this.isLoading = false});

  final Person person;
  final bool isLoading;

  /// On tablets the text would be too wide to read comfortably.
  static const double _maxContentWidth = 900;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final biography = person.biography;

    return Scaffold(
      // Outside the Skeletonizer, so the back button works while loading.
      appBar: AppBar(),
      body: Skeletonizer(
        enabled: isLoading,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: _maxContentWidth),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsetsDirectional.all(AppSpacing.md),
                  sliver: SliverList.list(
                    children: [
                      PersonHeader(person: person),
                      const SizedBox(height: AppSpacing.lg),
                      _SectionTitle(l10n.personBiography),
                      if (biography.isEmpty)
                        Text(l10n.personNoBiography)
                      else
                        ExpandableText(biography),
                      if (person.knownFor.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.lg),
                        _SectionTitle(l10n.personKnownFor),
                      ],
                    ],
                  ),
                ),
                if (person.knownFor.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.lg,
                    ),
                    sliver: _KnownForGrid(person: person),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The person's movies as a grid of posters that open their details.
class _KnownForGrid extends StatelessWidget {
  const _KnownForGrid({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final movies = person.knownFor;
    return SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 140,
        childAspectRatio: 2 / 3,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
      ),
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        final heroTag = 'person-${person.id}-${movie.id}';
        return MoviePosterCard(
          movie: movie,
          heroTag: heroTag,
          onTap: () => context.pushMovieDetails(movie, heroTag: heroTag),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
