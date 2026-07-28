import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/surah.dart';
import '../controllers/surah_controller.dart';

/// Quran surah list: search, filter chips, a "Last Read" hero, then a
/// responsive asymmetric grid of surah cards with a bottom mini-player.
class QuranListPage extends StatelessWidget {
  const QuranListPage({super.key});

  static const _filters = [
    'All Surahs',
    'Juz',
    'Makkah',
    'Madinah',
    'Bookmarks',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quran', style: AppTypography.titleLg),
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
          child: ListView(
            padding: const EdgeInsets.only(bottom: 140),
            children: [
              const SizedBox(height: AppSpacing.sm),
              const _SearchBar(),
              const SizedBox(height: AppSpacing.md),
              _filterChips(),
              const SizedBox(height: AppSpacing.lg),
              const Padding(
                padding: AppSpacing.screenPadding,
                child: _LastReadHero(),
              ),
              const SizedBox(height: AppSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.margin,
                ),
                child: _SurahGrid(),
              ),
              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterChips() {
    final controller = Get.find<SurahController>();
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: AppSpacing.screenPadding,
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          return Obx(() {
            final selected = controller.filter.value.index == i;
            return PressableScale(
              onTap: () => controller.setFilter(SurahFilter.values[i]),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary
                      : AppColors.surfaceContainerLowest,
                  borderRadius: AppRadii.pillRadius,
                  boxShadow: selected
                      ? AppShadows.primaryGlow(opacity: 0.25)
                      : null,
                  border: Border.all(
                    color: selected
                        ? Colors.transparent
                        : AppColors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  _filters[i],
                  style: AppTypography.labelSemibold.copyWith(
                    color: selected ? AppColors.onPrimary : AppColors.onSurface,
                    fontSize: 14,
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  const _SearchBar();

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SurahController>();
    return Padding(
      padding: AppSpacing.screenPadding,
      child: NeumorphicInsetField(
        child: Row(
          children: [
            Icon(Icons.search, color: AppColors.outline),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Search Surah, Juz, or Keyword...',
                  border: InputBorder.none,
                  isDense: true,
                ),
                onChanged: (value) => controller.searchQuery.value = value,
              ),
            ),
            if (_controller.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () {
                  _controller.clear();
                  controller.searchQuery.value = '';
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _LastReadHero extends StatelessWidget {
  const _LastReadHero();

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SurahController>();
    return Obx(() {
      final lr = controller.lastRead.value;
      if (lr == null) return const SizedBox.shrink();
      return ParallaxWidget(
        maxTranslationX: 8,
        maxTranslationY: 8,
        child: Container(
          padding: AppSpacing.cardInsets,
          decoration: BoxDecoration(
            borderRadius: AppRadii.cardRadius,
            boxShadow: AppShadows.card,
            image: DecorationImage(
              image: AssetImage(AppAssets.fatihaPage),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Color(0xCC00584A),
                BlendMode.darken,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: AppRadii.pillRadius,
                ),
                child: Text(
                  'LAST READ',
                  style: AppTypography.labelCaps.copyWith(color: Colors.white),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lr.surahName,
                        style: AppTypography.headlineLgMobile.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Ayah ${lr.ayah}',
                        style: AppTypography.bodyEnSm.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AnimatedProgressBar(
                value: lr.mushafProgress,
                minHeight: 6,
                color: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.25),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(lr.mushafProgress * 100).toStringAsFixed(0)}% Completed',
                    style: AppTypography.bodyEnSm.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    'Pages ${lr.pageStart}–${lr.pageEnd}',
                    style: AppTypography.bodyEnSm.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _SurahGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SurahController>();
    return Obx(() {
      if (controller.isLoading.value) {
        return Column(
          children: List.generate(
            4,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: SkeletonBox(
                height: 120,
                radius: AppRadii.cardRadius.topLeft.x,
              ),
            ),
          ),
        );
      }
      if (controller.error.value.isNotEmpty) {
        return ErrorStateView(
          message: controller.error.value,
          onRetry: controller.fetchSuwar,
        );
      }
      return Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          ResponsiveGrid(
            columns: 2,
            spacing: AppSpacing.md,
            runSpacing: AppSpacing.md,
            children: [
              ...controller.filteredSuwar.map((s) => _SurahCard(surah: s)),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
        ],
      );
    });
  }
}

class _SurahCard extends StatelessWidget {
  const _SurahCard({required this.surah});
  final Surah surah;

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: () => Get.toNamed(AppRoutes.ayahReader, arguments: surah),
      child: GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SurahOrnamentNumber(number: surah.id),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        surah.name,
                        textAlign: TextAlign.end,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodyAr.copyWith(
                          fontSize: 22,
                          height: 1.4,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'PAGES ${surah.startPage}–${surah.endPage}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelCaps.copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(surah.name, style: AppTypography.titleLg),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Flexible(child: PillTag(label: surah.revelationLabel)),
                // const SizedBox(width: AppSpacing.xs),
                // SizedBox(
                //   width: 36,
                //   height: 36,
                //   child: DecoratedBox(
                //     decoration: BoxDecoration(
                //       color: AppColors.secondaryContainer.withValues(
                //         alpha: 0.5,
                //       ),
                //       shape: BoxShape.circle,
                //     ),
                //     child: const Icon(
                //       Icons.play_arrow_rounded,
                //       color: AppColors.primary,
                //       size: 18,
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
