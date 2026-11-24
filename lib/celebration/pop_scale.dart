import 'package:flutter/animation.dart';

/// The squash-and-stretch pop shared by the journey nodes and the routine
/// card: dips, overshoots, then wobbles back to rest. Evaluate it with an
/// [AnimationController] running 0 to 1 (about 900ms feels right).
final TweenSequence<double> popScale = TweenSequence<double>([
  TweenSequenceItem(
    tween: Tween(begin: 1.0, end: 0.8).chain(CurveTween(curve: Curves.easeOut)),
    weight: 12,
  ),
  TweenSequenceItem(
    tween: Tween(
      begin: 0.8,
      end: 1.25,
    ).chain(CurveTween(curve: Curves.easeOut)),
    weight: 22,
  ),
  TweenSequenceItem(
    tween: Tween(
      begin: 1.25,
      end: 1.0,
    ).chain(CurveTween(curve: Curves.elasticOut)),
    weight: 66,
  ),
]);
