import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/error/failure_message.dart';
import 'package:movie_app/core/widgets/empty_view.dart';
import 'package:movie_app/core/widgets/error_view.dart';
import 'package:movie_app/features/search/presentation/bloc/search_bloc.dart';
import 'package:movie_app/features/search/presentation/widgets/search_results_grid.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// The area below the search field: one widget per [SearchState].
class SearchBody extends StatelessWidget {
  const SearchBody({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) => switch (state) {
        SearchInitial() => EmptyView(
          title: l10n.searchEmptyQuery,
          icon: Icons.search,
        ),
        SearchLoading() => const SearchLoadingGrid(),
        SearchLoaded() => SearchResultsGrid(state: state),
        SearchEmpty(:final query) => EmptyView(
          title: l10n.searchNoResults(query),
          icon: Icons.search_off,
        ),
        SearchError(:final failure) => ErrorView(
          message: failure.message(l10n),
          onRetry: () => context.read<SearchBloc>().add(const SearchRetried()),
        ),
      },
    );
  }
}
