import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/widgets/animations.dart';

/// A theme-aware architectural motif shared by the welcome screens.
class WelcomeArt extends StatelessWidget {
  const WelcomeArt({super.key, required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ExcludeSemantics(
      child: AspectRatio(
        aspectRatio: 1.05,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: width * .92,
                  height: width * .92,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        colors.primary.withValues(alpha: .14),
                        colors.surface.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: -.12,
                  child: Container(
                    width: width * .64,
                    height: width * .79,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: colors.primary.withValues(alpha: .18),
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(width),
                        bottom: const Radius.circular(32),
                      ),
                    ),
                  ),
                ),
                Floating(
                  amplitude: 4,
                  duration: const Duration(seconds: 6),
                  child: Container(
                    width: width * .64,
                    height: width * .79,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          colors.primary,
                          Color.lerp(colors.primary, colors.surface, .3)!,
                        ],
                      ),
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(width),
                        bottom: const Radius.circular(32),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colors.primary.withValues(alpha: .22),
                          blurRadius: 32,
                          offset: const Offset(0, 16),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          LucideIcons.sparkles,
                          size: width * .07,
                          color: colors.onPrimary.withValues(alpha: .65),
                        ),
                        SizedBox(height: width * .12),
                        Icon(icon, size: width * .23, color: colors.onPrimary),
                        SizedBox(height: width * .12),
                        Container(
                          width: width * .15,
                          height: 2,
                          color: colors.onPrimary.withValues(alpha: .4),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: width * .08,
                  bottom: width * .12,
                  child: Container(
                    padding: EdgeInsets.all(width * .045),
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.surface, width: 5),
                    ),
                    child: Icon(
                      LucideIcons.moon,
                      size: width * .085,
                      color: colors.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
