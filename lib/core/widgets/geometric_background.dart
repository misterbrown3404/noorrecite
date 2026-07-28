import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Level-0 background from DESIGN.md: a soft gradient wash overlaid with a
/// low-opacity (2–5%) Islamic 8-point-star geometric pattern, fixed to the
/// viewport. Wrap a screen body in this to get the "luminous void" base.
///
/// Optionally, an **Ambient Glow Aura** ([showAura]) can be layered between the
/// gradient and the pattern — a slow-breathing radial glow that gives the
/// "living, meditative" feel from the mockups. It's off by default so existing
/// screens are unchanged; home and splash opt in.
class GeometricBackground extends StatelessWidget {
  const GeometricBackground({
    super.key,
    required this.child,
    this.gradient = AppColors.backgroundGradient,
    this.patternOpacity = 0.04,
    this.showAura = false,
    this.auraColor = AppColors.primary,
    this.auraAlignment = const Alignment(0, -0.6),
  });

  final Widget child;
  final Gradient gradient;
  final double patternOpacity;

  /// Whether to render the slow-breathing ambient glow behind the pattern.
  final bool showAura;

  /// Colour of the ambient glow. Defaults to the emerald primary.
  final Color auraColor;

  /// Where the glow is centred (top-ish by default, echoing the mockups).
  final Alignment auraAlignment;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: gradient),
      child: CustomPaint(
        painter: _StarPatternPainter(opacity: patternOpacity),
        child: showAura
            ? _AmbientAura(
                color: auraColor,
                alignment: auraAlignment,
                child: child,
              )
            : child,
      ),
    );
  }
}

/// A full-screen radial glow that slowly breathes (scale + opacity) behind the
/// screen content. Native equivalent of the `aura-pulse` ambient effect.
class _AmbientAura extends StatefulWidget {
  const _AmbientAura({
    required this.child,
    required this.color,
    required this.alignment,
  });

  final Widget child;
  final Color color;
  final Alignment alignment;

  @override
  State<_AmbientAura> createState() => _AmbientAuraState();
}

class _AmbientAuraState extends State<_AmbientAura>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 8))
        ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final t = (math.sin(_c.value * 2 * math.pi) + 1) / 2; // 0..1
                return DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: widget.alignment,
                      radius: 0.7 + 0.25 * t,
                      colors: [
                        widget.color.withValues(alpha: 0.10 + 0.10 * t),
                        widget.color.withValues(alpha: 0),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
}

/// Paints a tiled field of 8-point stars as a faint watermark.
class _StarPatternPainter extends CustomPainter {
  _StarPatternPainter({required this.opacity});

  final double opacity;

  static const double _tile = 72;
  static const double _radius = 16;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primary.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (double y = _tile / 2; y < size.height + _tile; y += _tile) {
      for (double x = _tile / 2; x < size.width + _tile; x += _tile) {
        _drawStar(canvas, Offset(x, y), paint);
      }
    }
  }

  /// Draws an 8-point star as two overlaid squares (rotated 45°).
  void _drawStar(Canvas canvas, Offset center, Paint paint) {
    for (final rotation in [0.0, math.pi / 4]) {
      final path = Path();
      for (int i = 0; i < 4; i++) {
        final angle = rotation + i * math.pi / 2;
        final point = center +
            Offset(math.cos(angle) * _radius, math.sin(angle) * _radius);
        i == 0 ? path.moveTo(point.dx, point.dy) : path.lineTo(point.dx, point.dy);
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_StarPatternPainter oldDelegate) =>
      oldDelegate.opacity != opacity;
}
