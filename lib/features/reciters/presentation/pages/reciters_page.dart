import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../audio_player/presentation/controllers/audio_controller.dart';
import '../../domain/entities/reciter.dart';
import '../controllers/reciter_controller.dart';

/// Reciters directory (mockup: reciters_screen), reached via the Audio tab.
class RecitersPage extends StatelessWidget {
  const RecitersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReciterController>();
    return Scaffold(
      appBar: AppBar(
        title:const Text('Reciters'),
        actions: [
          HeaderIconAction(
            icon: Icons.settings_rounded,
            onTap: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: GeometricBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Fixed header: kept outside the reactive/scrolling area so the
              // search field never rebuilds (retains focus while typing) and
              // stays pinned above the results.
              Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.sm),
                    const PillTag(label: 'Featured Reciters'),
                    const SizedBox(height: AppSpacing.sm),
                    NeumorphicInsetField(
                      child: TextField(
                        onChanged: (value) =>
                            controller.searchQuery.value = value,
                        decoration: InputDecoration(
                          hintText: 'Search by name or style...',
                          hintStyle: AppTypography.bodyEnSm.copyWith(
                            color: AppColors.outline,
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: AppColors.outline,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) return _buildSkeletonGrid();
                  if (controller.error.value.isNotEmpty) {
                    return Padding(
                      padding: AppSpacing.screenPadding,
                      child: ErrorStateView(
                        message: controller.error.value,
                        onRetry: controller.fetchReciters,
                      ),
                    );
                  }
                  return _buildReciterGrid(controller);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const _gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    mainAxisSpacing: AppSpacing.md,
    crossAxisSpacing: AppSpacing.md,
    childAspectRatio: 0.68,
  );

  static const _gridPadding = EdgeInsets.fromLTRB(
    AppSpacing.md,
    0,
    AppSpacing.md,
    120,
  );

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: _gridPadding,
      gridDelegate: _gridDelegate,
      itemCount: 8,
      itemBuilder: (_, _) => const _ReciterCardSkeleton(),
    );
  }

  Widget _buildReciterGrid(ReciterController controller) {
    final reciters = controller.filteredReciters;
    // GridView.builder in a bounded Expanded lazily builds only the cards on
    // screen, so opening the page (and decoding portrait images) no longer
    // blocks the route transition on the full 100+ reciter directory.
    return GridView.builder(
      padding: _gridPadding,
      gridDelegate: _gridDelegate,
      itemCount: reciters.length,
      itemBuilder: (_, i) => _ReciterCard(reciter: reciters[i]),
    );
  }
}

class _ReciterCard extends StatelessWidget {
  const _ReciterCard({required this.reciter});
  final Reciter reciter;

  void _play(Reciter reciter) {
    Get.find<AudioController>().playReciter(reciter, startSurahNumber: 1);
    Get.toNamed(AppRoutes.audioPlayer);
  }

  @override
  Widget build(BuildContext context) {
    final imageAsset = AppAssets.reciterImage(reciter.id);
    return PressableScale(
      onTap: () => _play(reciter),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.tealEmeraldGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.surfaceContainerHigh,
                    ),
                    child: imageAsset != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(44),
                            child: Image.asset(
                              imageAsset,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.person_rounded,
                                color: AppColors.outline,
                                size: 48,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.person_rounded,
                            color: AppColors.outline,
                            size: 48,
                          ),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ],
            ),
            // Name + moshaf sit in a tight group so the avatar and play button
            // anchor the top/bottom while any spare height goes to the gaps.
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  reciter.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleLg,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  reciter.primaryMoshaf?.name ?? '',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.bodyEnSm,
                ),
              ],
            ),
            PressableScale(
              onTap: () => _play(reciter),
              child: NeuIconButton(
                icon: Icons.play_arrow_rounded,
                size: 52,
                onPressed: () => _play(reciter),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmering placeholder mirroring [_ReciterCard]'s layout while loading.
class _ReciterCardSkeleton extends StatelessWidget {
  const _ReciterCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Gradient ring skeleton
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.tealEmeraldGradient,
            ),
            child: const SkeletonBox.circle(size: 88),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SkeletonBox(width: 120, height: 18),
              const SizedBox(height: AppSpacing.xs),
              SkeletonBox(width: 80, height: 12),
            ],
          ),
          const SkeletonBox.circle(size: 52),
        ],
      ),
    );
  }
}
