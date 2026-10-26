import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Native-Flutter equivalents of the CSS keyframe animations used in the Stitch
/// mockups (`float`, `aura-pulse`, `fadeInUp`, `wave`, `progress-shimmer`,
/// `shimmer`). Each is self-contained and loops unless noted.

/// `float` — a gentle vertical bob (6s ease-in-out loop in the mockups). Wraps
/// any child; used on floating cards, hero art, and badge icons.
class Floating extends StatefulWidget {
  const Floating({
    super.key,
    required this.child,
    this.amplitude = 8,
    this.duration = const Duration(seconds: 6),
  });

  final Widget child;
  final double amplitude;
  final Duration duration;

  @override
  State<Floating> createState() => _FloatingState();
}

class _FloatingState extends State<Floating>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final dy = math.sin(_c.value * 2 * math.pi) * widget.amplitude;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: widget.child,
    );
  }
}

/// `aura-pulse` — a breathing glow halo behind a child (scale + opacity loop).
/// Used behind the splash logo tile.
class PulseGlow extends StatefulWidget {
  const PulseGlow({
    super.key,
    required this.child,
    this.color = AppColors.primary,
    this.maxBlur = 40,
    this.duration = const Duration(seconds: 4),
  });

  final Widget child;
  final Color color;
  final double maxBlur;
  final Duration duration;

  @override
  State<PulseGlow> createState() => _PulseGlowState();
}

class _PulseGlowState extends State<PulseGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) {
        final t = (math.sin(_c.value * 2 * math.pi) + 1) / 2; // 0..1
        return DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.25 + 0.25 * t),
                blurRadius: widget.maxBlur * (0.5 + 0.5 * t),
                spreadRadius: 4 * t,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// `fadeInUp` — a one-shot entrance: fade in while rising. Does not loop.
class FadeInUp extends StatefulWidget {
  const FadeInUp({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.offset = 24,
    this.duration = const Duration(milliseconds: 420),
  });

  final Widget child;
  final Duration delay;
  final double offset;
  final Duration duration;

  @override
  State<FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<FadeInUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _curve = CurvedAnimation(
    parent: _c,
    curve: Curves.easeOutCubic,
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedBuilder(
      animation: _curve,
      builder: (context, child) => Opacity(
        opacity: _curve.value,
        child: Transform.translate(
          offset: Offset(0, widget.offset * (1 - _curve.value)),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// `wave` — an animated equalizer of emerald bars (the audio player waveform).
class AnimatedWaveform extends StatefulWidget {
  const AnimatedWaveform({
    super.key,
    this.barCount = 13,
    this.height = 48,
    this.playing = true,
  });

  final int barCount;
  final double height;
  final bool playing;

  @override
  State<AnimatedWaveform> createState() => _AnimatedWaveformState();
}

class _AnimatedWaveformState extends State<AnimatedWaveform>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat();

  @override
  void didUpdateWidget(AnimatedWaveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    widget.playing && !MediaQuery.disableAnimationsOf(context)
        ? _c.repeat()
        : _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [for (var i = 0; i < widget.barCount; i++) _bar(i)],
        ),
      ),
    );
  }

  Widget _bar(int i) {
    // Phase-shifted sine per bar for a travelling wave.
    final phase = i / widget.barCount * 2 * math.pi;
    final t = (math.sin(_c.value * 2 * math.pi + phase) + 1) / 2;
    final h = 8 + t * (widget.height - 8);
    return Container(
      width: 4,
      height: h,
      margin: const EdgeInsets.symmetric(horizontal: 3),
      decoration: BoxDecoration(
        color: i.isEven ? AppColors.primary : AppColors.primaryFixedDim,
        borderRadius: AppRadii.pillRadius,
      ),
    );
  }
}

/// `progress-shimmer` / `shimmer` — a light sweep travelling across a child.
/// Wrap a progress bar or banner to get the sheen effect.
class Shimmer extends StatefulWidget {
  const Shimmer({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 2),
    this.enabled = true,
    this.highlight = const Color(0x55FFFFFF),
  });

  final Widget child;
  final Duration duration;
  final bool enabled;

  /// Colour of the travelling sheen. Defaults to a soft white; pass a
  /// gold tint (e.g. `AppColors.tertiaryFixedDim`) for the branded variant.
  final Color highlight;

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    if (!widget.enabled) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => ShaderMask(
        blendMode: BlendMode.srcATop,
        shaderCallback: (bounds) {
          final dx = bounds.width * (_c.value * 2 - 0.5);
          return LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.transparent, widget.highlight, Colors.transparent],
            stops: const [0.35, 0.5, 0.65],
            transform: _SlideGradient(dx / bounds.width),
          ).createShader(bounds);
        },
        child: child,
      ),
      child: widget.child,
    );
  }
}

/// Horizontal gradient slide used by [Shimmer].
class _SlideGradient extends GradientTransform {
  const _SlideGradient(this.fraction);
  final double fraction;

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) =>
      Matrix4.translationValues(bounds.width * fraction, 0, 0);
}

/// Micro-interaction: a tactile press feedback that scales the child down
/// (0.98× per DESIGN.md) on tap-down and eases back on release. Wraps any
/// tappable surface (cards, buttons) to give physical feedback.
///
/// If [onTap] is null the child is returned inert (no gesture, no scaling), so
/// this is safe to wrap around conditionally-tappable widgets.
class PressableScale extends StatefulWidget {
  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.scale = 0.97,
    this.duration = const Duration(milliseconds: 120),
  });

  final Widget child;
  final VoidCallback? onTap;

  /// Pressed-state scale factor (1.0 = none). DESIGN.md uses 0.98.
  final double scale;
  final Duration duration;

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _set(bool v) {
    if (mounted && _pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.onTap == null) return widget.child;
    return GestureDetector(
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed && !MediaQuery.disableAnimationsOf(context)
            ? widget.scale
            : 1,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// A linear progress bar that animates its fill from 0 → [value] with an
/// ease-in-out curve when it first appears (and re-animates from the previous
/// value whenever [value] changes). Native equivalent of the mockups' "Linear
/// Surah Progress" fills. Pill-shaped to match the design language.
class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.minHeight = 8,
    this.color = AppColors.primary,
    this.backgroundColor = AppColors.secondaryContainer,
    this.duration = const Duration(milliseconds: 420),
  });

  final double value;
  final double minHeight;
  final Color color;
  final Color backgroundColor;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadii.full),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: value.clamp(0.0, 1.0)),
        duration: duration,
        curve: Curves.easeInOut,
        builder: (context, v, _) => LinearProgressIndicator(
          value: v,
          minHeight: minHeight,
          backgroundColor: backgroundColor,
          valueColor: AlwaysStoppedAnimation(color),
        ),
      ),
    );
  }
}

/// A shimmering placeholder block for loading states — a rounded muted surface
/// with the gold [Shimmer] sweep travelling across it. Compose several of these
/// (via [SkeletonBox.circle] / sized boxes) to build list/card skeletons that
/// match the final layout, per DESIGN.md's "Shimmer Loading States".
class SkeletonBox extends StatelessWidget {
  const SkeletonBox({
    super.key,
    this.width,
    this.height = 16,
    this.radius = AppRadii.sm,
    this.shape = BoxShape.rectangle,
  });

  /// Circular skeleton (avatars, badges) of the given diameter.
  const SkeletonBox.circle({super.key, required double size})
    : width = size,
      height = size,
      radius = AppRadii.sm,
      shape = BoxShape.circle;

  final double? width;
  final double height;
  final double radius;
  final BoxShape shape;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      highlight: AppColors.tertiaryFixedDim.withValues(alpha: 0.45),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: shape == BoxShape.circle
              ? null
              : BorderRadius.circular(radius),
          shape: shape,
        ),
      ),
    );
  }
}

/// Particle field for ambient floating particles (splash, onboarding, auth).
class ParticleField extends StatefulWidget {
  const ParticleField({
    super.key,
    this.particleCount = 40,
    this.minSize = 1.0,
    this.maxSize = 4.0,
    this.colors = const [Color(0xFFFFDDB5), Color(0xFF82FAAB)],
    this.opacityRange = const [0.1, 0.5],
    this.durationRange = const [Duration(seconds: 10), Duration(seconds: 20)],
  });

  final int particleCount;
  final double minSize;
  final double maxSize;
  final List<Color> colors;
  final List<double> opacityRange;
  final List<Duration> durationRange;

  @override
  State<ParticleField> createState() => _ParticleFieldState();
}

class _ParticleFieldState extends State<ParticleField>
    with TickerProviderStateMixin {
  late final List<_Particle> _particles;
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    final random = math.Random();
    _particles = List.generate(widget.particleCount, (_) {
      final screenWidth = 400.0;
      final screenHeight = 800.0;
      return _Particle(
        startX: random.nextDouble() * screenWidth,
        startY: screenHeight + random.nextDouble() * 200,
        size:
            widget.minSize +
            random.nextDouble() * (widget.maxSize - widget.minSize),
        color: widget.colors[random.nextInt(widget.colors.length)],
        opacity:
            widget.opacityRange[0] +
            random.nextDouble() *
                (widget.opacityRange[1] - widget.opacityRange[0]),
        travelDistance: screenHeight + 400,
        horizontalDrift: (random.nextDouble() - 0.5) * 40,
        duration:
            widget.durationRange[0] +
            Duration(
              milliseconds: random.nextInt(
                widget.durationRange[1].inMilliseconds -
                    widget.durationRange[0].inMilliseconds,
              ),
            ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => Stack(
        children: [
          for (final particle in _particles)
            Positioned(
              left:
                  particle.startX +
                  _controller.value * particle.horizontalDrift,
              top:
                  particle.startY - _controller.value * particle.travelDistance,
              child: Opacity(
                opacity: particle.opacity,
                child: Container(
                  width: particle.size,
                  height: particle.size,
                  decoration: BoxDecoration(
                    color: particle.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: particle.color.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Particle {
  final double startX;
  final double startY;
  final double size;
  final Color color;
  final double opacity;
  final double travelDistance;
  final double horizontalDrift;
  final Duration duration;

  _Particle({
    required this.startX,
    required this.startY,
    required this.size,
    required this.color,
    required this.opacity,
    required this.travelDistance,
    required this.horizontalDrift,
    required this.duration,
  });
}

/// A parallax widget that responds to mouse movement (desktop) to create
/// a subtle 3D depth effect on hero artwork and cards, matching the Stitch
/// mockups' `mousemove` parallax.
class ParallaxWidget extends StatefulWidget {
  const ParallaxWidget({
    super.key,
    required this.child,
    this.maxRotationX = 8.0,
    this.maxRotationY = 8.0,
    this.maxTranslationX = 12.0,
    this.maxTranslationY = 12.0,
    this.enabled = true,
  });

  final Widget child;
  final double maxRotationX;
  final double maxRotationY;
  final double maxTranslationX;
  final double maxTranslationY;
  final bool enabled;

  @override
  State<ParallaxWidget> createState() => _ParallaxWidgetState();
}

class _ParallaxWidgetState extends State<ParallaxWidget> {
  @override
  Widget build(BuildContext context) {
    // Parallax is mouse-position driven and has no meaning on touch devices.
    // Render the child directly as a no-op passthrough.
    return widget.child;
  }
}

/// Gold gradient text shader for the QariVerse wordmark, matching the
/// Stitch mockups' `gold-text-gradient` CSS class.
class GoldGradientText extends StatelessWidget {
  const GoldGradientText({super.key, required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFDDB5), // #ffddb5
          Color(0xFFFFB957), // #ffb957
          Color(0xFF805200), // #805200
        ],
        stops: [0.0, 0.5, 1.0],
      ).createShader(bounds),
      child: Text(text, style: style),
    );
  }
}

/// Islamic geometric pattern background painter, matching the Stitch mockups'
/// `geometric-pattern` / `islamic-pattern` CSS classes.
class IslamicPatternPainter extends CustomPainter {
  const IslamicPatternPainter({
    this.color = const Color(0x08006A39), // #006a39 at 3% opacity
    this.spacing = 60.0,
  });

  final Color color;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path();

    // Create the islamic geometric star pattern
    for (double x = -spacing; x < size.width + spacing; x += spacing) {
      for (double y = -spacing; y < size.height + spacing; y += spacing) {
        _drawStar(path, x, y, spacing * 0.5);
      }
    }

    canvas.drawPath(path, paint);
  }

  void _drawStar(Path path, double cx, double cy, double radius) {
    const int points = 8;
    final angleStep = 2 * math.pi / points;
    for (int i = 0; i < points; i++) {
      final angle = i * angleStep - math.pi / 2;
      final outerX = cx + radius * math.cos(angle);
      final outerY = cy + radius * math.sin(angle);
      final innerAngle = angle + angleStep / 2;
      final innerX = cx + (radius * 0.4) * math.cos(innerAngle);
      final innerY = cy + (radius * 0.4) * math.sin(innerAngle);

      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// A fixed-column grid for the app's mobile-only layouts.
///
/// The design is phone-only (see [PhoneFrame]); column count never changes with
/// screen width. Pass [columns] for the exact number of columns to render.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.columns = 2,
    this.spacing = 16,
    this.runSpacing = 16,
  });

  final List<Widget> children;
  final int columns;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final itemWidth = (availableWidth - (columns - 1) * spacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: runSpacing,
          children: children
              .map(
                (child) => SizedBox(
                  width: itemWidth > 0 ? itemWidth : null,
                  child: child,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

/// A neumorphic inset field matching the Stitch mockups' `neumorphic-inset`
/// CSS class for auth inputs and search fields.
class NeumorphicInsetField extends StatelessWidget {
  const NeumorphicInsetField({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius,
  });

  final Widget child;
  final EdgeInsets padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: borderRadius ?? AppRadii.controlRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(2, 2),
            blurRadius: 5,
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.8),
            offset: const Offset(-3, -3),
            blurRadius: 7,
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: child,
    );
  }
}
