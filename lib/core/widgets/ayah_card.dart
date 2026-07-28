import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'glass_card.dart';
import 'surah_ornament_number.dart';

/// The design centerpiece (DESIGN.md "Ayah Cards"): a high-blur glass panel
/// with centered Arabic (Amiri), a gold-accented surah ornament for the verse
/// number, and an optional translation shown 25–30% smaller beneath.
///
/// Used in the reader, bookmarks, and daily-reflection surfaces.
class AyahCard extends StatelessWidget {
  const AyahCard({
    super.key,
    required this.arabic,
    this.translation,
    this.surahName,
    this.ayahNumber,
    this.note,
    this.trailing,
    this.onTap,
  });

  final String arabic;
  final String? translation;

  /// e.g. "AL-BAQARAH". Rendered as an overline with the verse marker.
  final String? surahName;
  final int? ayahNumber;

  /// Optional personal note/reflection block shown beneath the translation.
  final String? note;

  /// Optional trailing widget in the header row (e.g. a bookmark toggle).
  final Widget? trailing;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (surahName != null || ayahNumber != null) _header(),
          if (surahName != null || ayahNumber != null)
            const SizedBox(height: AppSpacing.lg),
          // Arabic ayah — centered, RTL, generous line height for Tashkeel.
          Text(
            arabic,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: AppTypography.bodyAr,
          ),
          if (translation != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              translation!,
              textAlign: TextAlign.center,
              // ~28% smaller than the 24px Arabic, per DESIGN.md hierarchy.
              style: AppTypography.bodyEnSm.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
          if (note != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _noteBlock(note!),
          ],
        ],
      ),
    );
  }

  Widget _header() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (ayahNumber != null) ...[
          SurahOrnamentNumber(
            number: ayahNumber!,
            size: 40,
            gold: true,
            arabicNumerals: true,
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (surahName != null)
                Text(
                  surahName!.toUpperCase(),
                  style: AppTypography.labelCaps
                      .copyWith(color: AppColors.primary),
                ),
              if (ayahNumber != null)
                Text('Verse $ayahNumber', style: AppTypography.bodyEnSm),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }

  Widget _noteBlock(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: AppRadii.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded,
                  size: 16, color: AppColors.tertiary),
              const SizedBox(width: AppSpacing.xs),
              Text('My Notes',
                  style: AppTypography.labelCaps
                      .copyWith(color: AppColors.tertiary)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(text, style: AppTypography.bodyEnSm),
        ],
      ),
    );
  }
}
