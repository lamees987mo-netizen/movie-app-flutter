import 'package:flutter/material.dart';
import 'package:movie_app/core/theme/app_theme.dart';
import 'package:movie_app/features/movies/presentation/utils/youtube.dart';
import 'package:movie_app/features/movies/presentation/widgets/trailer/trailer_player.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// Builds the video player. [onError] must be called when the video
/// cannot be played, so the page can offer "Open in YouTube" instead.
typedef TrailerPlayerBuilder =
    Widget Function(
      BuildContext context,
      String youtubeKey,
      VoidCallback onError,
    );

/// Full-screen page that plays a movie trailer inside the app.
///
/// "Open in YouTube" (in the app bar, and as a button when the player
/// fails) is the fallback: it opens the same video in the YouTube app or
/// the browser.
class TrailerPage extends StatefulWidget {
  const TrailerPage({
    required this.youtubeKey,
    this.title,
    this.playerBuilder = defaultPlayerBuilder,
    super.key,
  });

  /// The YouTube video id, e.g. `dQw4w9WgXcQ`.
  final String youtubeKey;

  /// The movie title for the app bar. `null` when opened from a link.
  final String? title;

  /// Builds the player. Tests pass a fake, because a real WebView cannot
  /// run in widget tests.
  final TrailerPlayerBuilder playerBuilder;

  /// The real player, in the language of the app.
  static Widget defaultPlayerBuilder(
    BuildContext context,
    String youtubeKey,
    VoidCallback onError,
  ) {
    return TrailerPlayer(
      youtubeKey: youtubeKey,
      onError: onError,
      languageCode: Localizations.localeOf(context).languageCode,
    );
  }

  @override
  State<TrailerPage> createState() => _TrailerPageState();
}

class _TrailerPageState extends State<TrailerPage> {
  bool _hasError = false;

  void _onPlayerError() {
    if (mounted) setState(() => _hasError = true);
  }

  void _openOnYoutube() => openOnYoutube(context, widget.youtubeKey);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      // Black like a cinema, in both light and dark mode.
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.title ?? l10n.trailerTitle),
        actions: [
          IconButton(
            tooltip: l10n.trailerOpenInYoutube,
            onPressed: _openOnYoutube,
            icon: const Icon(Icons.open_in_new),
          ),
        ],
      ),
      body: Center(
        child: _hasError
            ? _TrailerError(onOpenOnYoutube: _openOnYoutube)
            : widget.playerBuilder(context, widget.youtubeKey, _onPlayerError),
      ),
    );
  }
}

/// Shown instead of the player when the video cannot be played here.
class _TrailerError extends StatelessWidget {
  const _TrailerError({required this.onOpenOnYoutube});

  final VoidCallback onOpenOnYoutube;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.white70),
          const SizedBox(height: AppSpacing.md),
          Text(
            l10n.trailerError,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton.icon(
            onPressed: onOpenOnYoutube,
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.trailerOpenInYoutube),
          ),
        ],
      ),
    );
  }
}
