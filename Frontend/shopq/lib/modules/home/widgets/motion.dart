import 'package:flutter/material.dart';

/// Lightweight entrance + interaction motion helpers for the user app.
///
/// [FadeSlideIn] plays a one-shot fade + upward slide when a widget first
/// mounts. Use [FadeSlideIn.stagger] to build a list whose children appear one
/// after another. [PressableScale] gives buttons/cards a subtle tap shrink.

class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;
  final double offsetY;
  final Curve curve;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 420),
    this.delay = Duration.zero,
    this.offsetY = 24,
    this.curve = Curves.easeOutCubic,
  });

  /// Wrap each item in [children] with an incrementally delayed entrance, so a
  /// column/list reveals top-to-bottom. [step] is the gap between items;
  /// [maxStagger] caps the total delay so long lists don't lag.
  static List<Widget> stagger(
    List<Widget> children, {
    Duration step = const Duration(milliseconds: 70),
    Duration maxStagger = const Duration(milliseconds: 600),
    double offsetY = 24,
  }) {
    return [
      for (int i = 0; i < children.length; i++)
        FadeSlideIn(
          delay: Duration(
            milliseconds: (step.inMilliseconds * i).clamp(0, maxStagger.inMilliseconds),
          ),
          offsetY: offsetY,
          child: children[i],
        ),
    ];
  }

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _fade =
      CurvedAnimation(parent: _c, curve: widget.curve);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: Offset(0, widget.offsetY / 100),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _c, curve: widget.curve));

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      Future.delayed(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Scales [child] down briefly while pressed — a tactile tap response for
/// cards and buttons. Forwards taps to [onTap].
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  const PressableScale({super.key, required this.child, this.onTap, this.scale = 0.96});

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _down = true),
      onTapUp: (_) => setState(() => _down = false),
      onTapCancel: () => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
