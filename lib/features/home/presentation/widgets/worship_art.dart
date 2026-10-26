import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Original bundled SVGs, animated by Flutter (no SVG SMIL dependency).
class WorshipArt extends StatefulWidget {
  const WorshipArt({super.key, required this.azkar, this.size = 130});
  final bool azkar;
  final double size;
  @override
  State<WorshipArt> createState() => _WorshipArtState();
}

class _WorshipArtState extends State<WorshipArt>
    with SingleTickerProviderStateMixin {
  late final _motion = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 5),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _motion.stop();
      _motion.value = 0;
    } else if (!_motion.isAnimating) {
      _motion.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: RepaintBoundary(
      child: AnimatedBuilder(
        animation: _motion,
        child: SvgPicture.asset(
          'assets/illustrations/${widget.azkar ? 'azkar_beads' : 'prayer_arch'}.svg',
          width: widget.size,
          height: widget.size,
        ),
        builder: (_, child) => Transform.translate(
          offset: Offset(0, -5 * Curves.easeInOut.transform(_motion.value)),
          child: Transform.rotate(
            angle: widget.azkar ? (_motion.value - .5) * .045 : 0,
            child: child,
          ),
        ),
      ),
    ),
  );
}
