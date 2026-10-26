import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../reciters/domain/entities/reciter.dart';
import '../../../reciters/presentation/controllers/reciter_controller.dart';

/// Home "Popular Reciters" horizontal carousel. Shows skeletons while the
/// reciter list loads, then the first ten reciters as tappable cards.
class PopularReciters extends StatelessWidget {
  const PopularReciters({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.screenPadding,
          child: SectionHeader(
            title: 'Popular Reciters',
            actionLabel: 'VIEW ALL',
            onAction: () => Get.toNamed(AppRoutes.reciters),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 200,
          child: Obx(() {
            final controller = Get.find<ReciterController>();
            if (controller.isLoading.value) {
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: AppSpacing.screenPadding,
                itemCount: 4,
                separatorBuilder: (_, _) =>
                    const SizedBox(width: AppSpacing.md),
                itemBuilder: (context, _) => const _ReciterCardSkeleton(),
              );
            }
            final reciters = controller.reciters.take(10).toList();
            return ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.screenPadding,
              itemCount: reciters.length,
              separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
              itemBuilder: (context, i) => _ReciterCard(reciter: reciters[i]),
            );
          }),
        ),
      ],
    );
  }
}

class _ReciterCard extends StatelessWidget {
  const _ReciterCard({required this.reciter});
  final Reciter reciter;

  @override
  Widget build(BuildContext context) {
    final imageAsset = AppAssets.reciterImage(reciter.id);
    return PressableScale(
      onTap: () => Get.toNamed(AppRoutes.reciters),
      child: SizedBox(
        width: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 150,
              width: 150,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: AppRadii.cardRadius,
                boxShadow: AppShadows.card,
                gradient: AppColors.tealEmeraldGradient,
              ),
              child: imageAsset != null
                  ? Image.asset(
                      imageAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _ReciterAvatarFallback(),
                    )
                  : const _ReciterAvatarFallback(),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              reciter.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.labelSemibold,
            ),
            Text(
              reciter.primaryMoshaf?.name ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodyEnSm,
            ),
          ],
        ),
      ),
    );
  }
}

/// Generic avatar shown when a reciter has no mapped portrait, or the asset
/// fails to decode.
class _ReciterAvatarFallback extends StatelessWidget {
  const _ReciterAvatarFallback();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(LucideIcons.userRound, color: Colors.white, size: 56),
    );
  }
}

class _ReciterCardSkeleton extends StatelessWidget {
  const _ReciterCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SkeletonBox(
            width: 150,
            height: 150,
            radius: AppRadii.cardRadius.topLeft.x,
          ),
          const SizedBox(height: AppSpacing.sm),
          const SkeletonBox(width: 120, height: 14),
          const SizedBox(height: AppSpacing.xs),
          const SkeletonBox(width: 80, height: 12),
        ],
      ),
    );
  }
}
