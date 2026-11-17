import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Plays one YouTube video inside the app (a WebView running YouTube's
/// official iframe player).
///
/// It starts playing right away, shows YouTube's own controls, and goes
/// fullscreen with the fullscreen button or when the phone is turned
/// sideways. When YouTube reports an error (e.g. the owner does not allow
/// playing the video outside YouTube) it calls [onError].
///
/// Widget tests cannot run a WebView, so `TrailerPage` builds this widget
/// through a builder that tests replace with a fake.
class TrailerPlayer extends StatefulWidget {
  const TrailerPlayer({
    required this.youtubeKey,
    required this.onError,
    this.languageCode = 'en',
    super.key,
  });

  /// The YouTube video id, e.g. `dQw4w9WgXcQ`.
  final String youtubeKey;

  /// Called (at most once) when the player cannot play the video.
  final VoidCallback onError;

  /// Language of the player's buttons and captions, e.g. `ar`.
  final String languageCode;

  @override
  State<TrailerPlayer> createState() => _TrailerPlayerState();
}

class _TrailerPlayerState extends State<TrailerPlayer> {
  late final YoutubePlayerController _controller;
  StreamSubscription<YoutubePlayerValue>? _subscription;
  bool _reportedError = false;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.youtubeKey,
      autoPlay: true,
      params: YoutubePlayerParams(
        showFullscreenButton: true,
        interfaceLanguage: widget.languageCode,
        captionLanguage: widget.languageCode,
      ),
    )..setFullScreenListener(_onFullScreenChanged);

    _subscription = _controller.stream.listen((value) {
      if (value.hasError && !_reportedError) {
        _reportedError = true;
        widget.onError();
      }
    });
  }

  /// Hides the status and navigation bars while the video is fullscreen.
  void _onFullScreenChanged(bool isFullScreen) {
    unawaited(
      SystemChrome.setEnabledSystemUIMode(
        isFullScreen ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge,
      ),
    );
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    unawaited(_controller.close());
    // Leaving the page while fullscreen must bring the system bars back.
    _onFullScreenChanged(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      backgroundColor: Colors.black,
    );
  }
}
