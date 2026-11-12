import 'package:flutter/material.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// Placeholder: the watchlist feature replaces this with the real screen.
class WatchlistPage extends StatelessWidget {
  const WatchlistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).navWatchlist)),
    );
  }
}
