import 'package:flutter/material.dart';

import '../utils/design_tokens.dart';

/// Fades and gently slides its [child] up into place on first build.
///
/// Pass the item's [index] in a list/grid to stagger the entrance. The delay is
/// capped so long lists never wait noticeably. Cheap: animates transform +
/// opacity only (no layout), respecting the calm motion rhythm in [AppMotion].
class AnimatedEntrance extends StatefulWidget {
  const AnimatedEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.maxStagger = 10,
  });

  final Widget child;
  final int index;
  final int maxStagger;

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance> {
  bool _shown = false;

  @override
  void initState() {
    super.initState();
    final steps = widget.index.clamp(0, widget.maxStagger);
    Future.delayed(AppMotion.stagger * steps, () {
      if (mounted) setState(() => _shown = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _shown ? Offset.zero : const Offset(0, 0.08),
      duration: AppMotion.medium,
      curve: AppMotion.enter,
      child: AnimatedOpacity(
        opacity: _shown ? 1 : 0,
        duration: AppMotion.medium,
        curve: AppMotion.enter,
        child: widget.child,
      ),
    );
  }
}

/// Subtly scales its [child] down while pressed, then springs back.
///
/// Uses a [Listener] (pointer observer) so it never consumes gestures: keep the
/// child's own [InkWell]/[GestureDetector] for ripple and tap handling.
class PressableScale extends StatefulWidget {
  const PressableScale({super.key, required this.child, this.scale = 0.97});

  final Widget child;
  final double scale;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  double _scale = 1;

  void _press() => setState(() => _scale = widget.scale);
  void _release() => setState(() => _scale = 1);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => _press(),
      onPointerUp: (_) => _release(),
      onPointerCancel: (_) => _release(),
      child: AnimatedScale(
        scale: _scale,
        duration: AppMotion.fast,
        curve: AppMotion.enter,
        child: widget.child,
      ),
    );
  }
}
