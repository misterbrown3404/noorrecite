import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/duration_format.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/prayer_times_controller.dart';

/// Home "Next Prayer" hero card. Shows a live per-second countdown (isolated in
/// a leaf [Obx] so only the countdown label repaints), the next prayer's name
/// and clock time, with skeleton/error fallbacks.
class NextPrayerCard extends StatelessWidget {
  const NextPrayerCard({super.key, required this.controller});
  final PrayerTimesController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final next = controller.nextPrayer.value;
      final loading = controller.isLoading.value;
      final error = controller.error.value;

      if (loading) {
        return const _Skeleton();
      }
      if (error.isNotEmpty) {
        return _ErrorCard(message: error, onRetry: controller.loadPrayerTimes);
      }
      if (next == null) {
        return _ErrorCard(
          message: 'Unable to load prayer times',
          onRetry: controller.loadPrayerTimes,
        );
      }

      return Container(
        padding: AppSpacing.cardInsets,
        decoration: BoxDecoration(
          borderRadius: AppRadii.cardRadius,
          boxShadow: AppShadows.card,
          image: DecorationImage(
            image: AssetImage(AppAssets.mosqueLandscape),
            fit: BoxFit.cover,
            colorFilter: const ColorFilter.mode(
              Color(0xCC061A14),
              BlendMode.colorDodge,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: AppRadii.pillRadius,
                  ),
                  child: Text(
                    'NEXT PRAYER',
                    style: AppTypography.labelCaps.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ),
                Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${next.name.toUpperCase()} IN',
                          style: AppTypography.labelCaps.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        // Leaf Obx: only this countdown label repaints each
                        // second; the surrounding card shell stays put.
                        Obx(
                          () => Text(
                            DurationFormat.hms(controller.remaining.value),
                            style: AppTypography.titleLg.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(
                      duration: 1000.ms,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
              ],
            ),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      next.name,
                      style: AppTypography.titleLg.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      next.formattedTime,
                      style: AppTypography.bodyEnSm.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                PressableScale(
                  onTap: () {},
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_active_outlined,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        borderRadius: AppRadii.cardRadius,
        boxShadow: AppShadows.card,
        image: DecorationImage(
          image: AssetImage(AppAssets.mosqueLandscape),
          fit: BoxFit.cover,
          colorFilter: const ColorFilter.mode(
            Color(0xCC061A14),
            BlendMode.colorDodge,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: AppRadii.pillRadius,
                ),
              ),
              Container(
                width: 80,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 48),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 24,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 100,
                    height: 16,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ],
              ),
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppSpacing.cardInsets,
      decoration: BoxDecoration(
        borderRadius: AppRadii.cardRadius,
        boxShadow: AppShadows.card,
        image: DecorationImage(
          image: AssetImage(AppAssets.mosqueLandscape),
          fit: BoxFit.cover,
          colorFilter: const ColorFilter.mode(
            Color(0xCC061A14),
            BlendMode.colorDodge,
          ),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            message,
            style: AppTypography.bodyEnSm.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          PressableScale(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: AppRadii.pillRadius,
              ),
              child: Text(
                'Retry',
                style: AppTypography.labelSemibold.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
