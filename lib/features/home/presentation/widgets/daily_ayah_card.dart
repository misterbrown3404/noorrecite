import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../bookmarks/domain/entities/bookmark.dart';
import '../../../bookmarks/presentation/controllers/bookmarks_controller.dart';
import '../../../daily_ayah/domain/entities/daily_ayah.dart';
import '../../../daily_ayah/presentation/controllers/daily_ayah_controller.dart';

/// Home "Daily Ayah" hero card. Tapping opens the daily reflection page; the
/// body shows the ayah (Arabic + translation + reference) with share/favorite
/// actions, plus loading and error fallbacks.
class DailyAyahCard extends StatelessWidget {
  const DailyAyahCard({super.key});

  @override
  Widget build(BuildContext context) {
    final dailyAyahController = Get.find<DailyAyahController>();
    return PressableScale(
      onTap: () => Get.toNamed(AppRoutes.dailyReflection),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: AppRadii.cardRadius,
          boxShadow: AppShadows.primaryGlow(opacity: 0.3),
        ),
        child: Obx(() {
          if (dailyAyahController.isLoading.value) {
            return const _DailyAyahLoading();
          }
          if (dailyAyahController.error.value.isNotEmpty) {
            return ErrorStateView(
              message: dailyAyahController.error.value,
              onRetry: dailyAyahController.fetchDailyAyah,
            );
          }
          final ayah = dailyAyahController.dailyAyah.value;
          if (ayah == null) return const SizedBox.shrink();
          return Column(
            children: [
              Text(
                'DAILY AYAH',
                style: AppTypography.labelCaps.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                ayah.arabic,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: AppTypography.bodyAr.copyWith(
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                ayah.translation,
                textAlign: TextAlign.center,
                style: AppTypography.bodyEnSm.copyWith(
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.tertiaryFixedDim),
                  borderRadius: AppRadii.pillRadius,
                ),
                child: Text(
                  ayah.reference.toUpperCase(),
                  style: AppTypography.labelCaps.copyWith(
                    color: AppColors.tertiaryFixed,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _CircleGlyph(
                    icon: Icons.share_outlined,
                    onTap: () => SharePlus.instance.share(
                      ShareParams(
                        text:
                            '${ayah.reference} \n\n${ayah.arabic}\n\n${ayah.translation}',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  _DailyAyahFavoriteGlyph(ayah: ayah),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _DailyAyahLoading extends StatelessWidget {
  const _DailyAyahLoading();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 200,
          height: 24,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: AppRadii.pillRadius,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: 150,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ],
    );
  }
}

class _CircleGlyph extends StatelessWidget {
  const _CircleGlyph({required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _DailyAyahFavoriteGlyph extends StatelessWidget {
  const _DailyAyahFavoriteGlyph({required this.ayah});
  final DailyAyah ayah;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<BookmarksController>();
    return Obx(() {
      final saved = controller.isBookmarked(ayah.surahId, ayah.ayahNumber);
      return PressableScale(
        onTap: () => controller.toggle(
          Bookmark(
            surahId: ayah.surahId,
            surahName: ayah.reference,
            ayah: ayah.ayahNumber,
            arabic: ayah.arabic,
            translation: ayah.translation,
            reference: ayah.reference,
            isFavorite: true,
            savedAtMs: DateTime.now().millisecondsSinceEpoch,
          ),
        ),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
    });
  }
}
