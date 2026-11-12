import 'package:flutter/material.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// Placeholder: the movies feature replaces this with the real home screen.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context).appTitle)),
    );
  }
}
