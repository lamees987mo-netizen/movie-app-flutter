import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/core/di/injection.dart';
import 'package:movie_app/features/search/presentation/bloc/search_bloc.dart';
import 'package:movie_app/features/search/presentation/widgets/search_body.dart';
import 'package:movie_app/features/search/presentation/widgets/search_field.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:movie_app/features/settings/presentation/cubit/settings_state.dart';

/// The Search tab.
///
/// This widget only creates the bloc; [SearchView] draws the screen.
/// Keeping them apart lets widget tests give the view a mock bloc,
/// without the service locator or the network.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SearchBloc>(),
      // TMDB returns titles in the app's language, so search again when
      // the language changes (like Home and "See all" reload).
      child: BlocListener<SettingsCubit, SettingsState>(
        listenWhen: (previous, current) => previous.locale != current.locale,
        listener: (context, _) =>
            context.read<SearchBloc>().add(const SearchLanguageChanged()),
        child: const SearchView(),
      ),
    );
  }
}

/// Draws the Search screen for the [SearchBloc] above it.
class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const SearchField()),
      body: const SearchBody(),
    );
  }
}
