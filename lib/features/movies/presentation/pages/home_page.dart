import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/core/widgets/offline_banner.dart';
import 'package:movie_app/features/movies/domain/entities/movie_category.dart';
import 'package:movie_app/features/movies/presentation/cubit/movie_section_cubit.dart';
import 'package:movie_app/features/movies/presentation/widgets/movie_section.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_state.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// The Home tab: a vertical list of [MovieSection]s.
///
/// Each section has its own [MovieSectionCubit], so sections load, fail
/// and retry independently.
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// The sections shown on Home, top to bottom.
  ///
  /// To add a section, add its category here; nothing else changes.
  static const List<MovieCategory> _categories = [
    MovieCategory.trending,
    MovieCategory.nowPlaying,
    MovieCategory.topRated,
    MovieCategory.upcoming,
  ];

  /// One cubit per section, created here (not in a `BlocProvider(create:)`)
  /// because pull-to-refresh must reach all of them. Since this State
  /// creates them, it also closes them in [dispose].
  late final List<MovieSectionCubit> _cubits = [
    for (final category in _categories) sl<MovieSectionCubit>(param1: category),
  ];

  /// Shows the "You're offline" bar. Without internet the repository
  /// returns the cached first page, so the sections still have movies.
  bool _isOffline = false;
  late final StreamSubscription<List<ConnectivityResult>> _connectivity;

  @override
  void initState() {
    super.initState();
    // Not awaited on purpose: each cubit emits its states as it goes.
    for (final cubit in _cubits) {
      unawaited(cubit.load());
    }

    final connectivity = sl<Connectivity>();
    unawaited(connectivity.checkConnectivity().then(_onConnectivityChanged));
    _connectivity = connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  void _onConnectivityChanged(List<ConnectivityResult> results) {
    if (!mounted) return;
    final isOffline = results.every((r) => r == ConnectivityResult.none);
    if (isOffline == _isOffline) return;

    setState(() => _isOffline = isOffline);
    // Back online: replace cached (or failed) sections with fresh data.
    if (!isOffline) unawaited(_refresh());
  }

  @override
  void dispose() {
    unawaited(_connectivity.cancel());
    for (final cubit in _cubits) {
      unawaited(cubit.close());
    }
    super.dispose();
  }

  /// The pull-to-refresh spinner stays until every section has finished.
  Future<void> _refresh() =>
      Future.wait([for (final cubit in _cubits) cubit.refresh()]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).appTitle)),
      // TMDB returns titles in the app's language (LanguageInterceptor), so
      // when the language changes, reload what is already on screen.
      body: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) => previous.locale != current.locale,
        listener: (context, _) => unawaited(_refresh()),
        child: Column(
          children: [
            if (_isOffline) const OfflineBanner(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  // Lets the user pull to refresh even when content is short.
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsetsDirectional.symmetric(
                    vertical: AppSpacing.md,
                  ),
                  itemCount: _cubits.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.lg),
                  itemBuilder: (context, index) {
                    final cubit = _cubits[index];
                    // `.value`: this State, not the provider, owns the cubit.
                    return BlocProvider.value(
                      value: cubit,
                      child: MovieSection(category: cubit.category),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
