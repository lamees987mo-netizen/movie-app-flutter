import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_app/features/search/presentation/bloc/search_bloc.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// The search text field shown in the app bar, with a clear button.
///
/// Every change is sent to the [SearchBloc] as it is typed; the bloc
/// decides when to actually search (debounce).
class SearchField extends StatefulWidget {
  const SearchField({super.key});

  @override
  State<SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<SearchField> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String query) =>
      context.read<SearchBloc>().add(SearchQueryChanged(query));

  void _clear() {
    _controller.clear();
    // `clear()` does not call `onChanged`, so tell the bloc ourselves.
    _onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: AppLocalizations.of(context).searchHint,
        prefixIcon: const Icon(Icons.search),
        border: InputBorder.none,
        // Only this button rebuilds when the text changes; it is shown
        // only when there is something to clear.
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) => value.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  tooltip: MaterialLocalizations.of(context).clearButtonTooltip,
                  icon: const Icon(Icons.clear),
                  onPressed: _clear,
                ),
        ),
      ),
    );
  }
}
