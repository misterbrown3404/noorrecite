import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The gold-accented "Surah Ornament" verse marker from DESIGN.md — a diamond
/// (8-point-star inspired) badge holding an ayah or surah number. Seen as the
/// green diamonds in the surah list and the gold "٢٥٥" markers on bookmarks.
class SurahOrnamentNumber extends StatelessWidget {
  const SurahOrnamentNumber({
    super.key,
    required this.number,
    this.size = 44,
    this.gold = false,
    this.arabicNumerals = false,
  });

  final int number;

  final double size;

  /// Gold treatment (used for bookmark ayah markers); otherwise emerald.
  final bool gold;

  /// Render the number in Eastern-Arabic numerals (٠١٢٣…).
  final bool arabicNumerals;

  @override
  Widget build(BuildContext context) {
    final fill = gold
        ? AppColors.tertiaryContainer
        : AppColors.secondaryContainer.withValues(alpha: 0.6);
    final fg = gold ? AppColors.onTertiary : AppColors.onSecondaryContainer;

    return Transform.rotate(
      angle: 0.785398, // 45° — diamond orientation
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(size * 0.28),
        ),
        alignment: Alignment.center,
        child: Transform.rotate(
          angle: -0.785398,
          child: Text(
            arabicNumerals ? _toArabic(number) : '$number',
            style: AppTypography.labelSemibold.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  static String _toArabic(int n) {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var s = '$n';
    for (var i = 0; i < western.length; i++) {
      s = s.replaceAll(western[i], eastern[i]);
    }
    return s;
  }
}
