import 'package:flutter/material.dart';
import 'package:movie_app/l10n/generated/app_localizations.dart';

/// A long text cut after [maxLines], with a "Show more" / "Show less"
/// button. The button only appears when the text is really cut.
class ExpandableText extends StatefulWidget {
  const ExpandableText(this.text, {this.maxLines = 5, super.key});

  final String text;
  final int maxLines;

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _expanded = false;

  /// Measures the text off-screen to know if it needs more than
  /// [ExpandableText.maxLines] lines at this width.
  bool _isTooLong(BuildContext context, double maxWidth) {
    final painter = TextPainter(
      text: TextSpan(
        text: widget.text,
        style: DefaultTextStyle.of(context).style,
      ),
      maxLines: widget.maxLines,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);
    final tooLong = painter.didExceedMaxLines;
    painter.dispose();
    return tooLong;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final tooLong = _isTooLong(context, constraints.maxWidth);
        final collapsed = tooLong && !_expanded;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: collapsed ? widget.maxLines : null,
              overflow: collapsed ? TextOverflow.ellipsis : null,
            ),
            if (tooLong)
              TextButton(
                onPressed: () => setState(() => _expanded = !_expanded),
                child: Text(
                  _expanded ? l10n.commonShowLess : l10n.commonShowMore,
                ),
              ),
          ],
        );
      },
    );
  }
}
