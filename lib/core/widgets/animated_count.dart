import 'package:flutter/material.dart';

/// Animates a whole-number counter to a new value whenever it changes — a subtle
/// count-up (no flash, no jump), so a live number feels premium instead of
/// snapping. Counts up from 0 on first appearance, then tweens from the old value
/// to the new one on every change.
///
/// Deliberately tiny: it animates an `int` and renders it with [style]. It is the
/// **single source** for animated counters (dashboard metrics, the review summary,
/// drill counts) so each surface doesn't re-roll its own `TweenAnimationBuilder`.
/// Keep it minimal — no formatting/locale knobs beyond an optional prefix/suffix.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    super.key,
    required this.value,
    this.style,
    this.duration = const Duration(milliseconds: 600),
    this.prefix = '',
    this.suffix = '',
    this.maxLines,
  });

  final int value;
  final TextStyle? style;
  final Duration duration;
  final String prefix;
  final String suffix;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      // `begin: 0` only applies on first build (count-up on appear); a later value
      // change tweens from the current animated value to the new end.
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text(
        '$prefix${v.round()}$suffix',
        style: style,
        maxLines: maxLines,
        overflow: maxLines == null ? null : TextOverflow.ellipsis,
      ),
    );
  }
}
