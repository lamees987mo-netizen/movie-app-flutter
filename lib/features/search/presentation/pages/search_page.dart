import 'package:flutter/material.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// Placeholder: the search feature replaces this with the real screen.
class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).navSearch)),
    );
  }
}
