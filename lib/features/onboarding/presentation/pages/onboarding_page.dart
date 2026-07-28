import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../l10n/app_localizations.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Onboarding pager (mockups: onboarding_discover / _listen / _reflect).
/// Three value-prop slides with page dots and Next/Get Started controls.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  late List<_Slide> _slides;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context)!;
    _slides = [
      _Slide(
        title: l10n.onboardingSlide1Title,
        body: l10n.onboardingSlide1Body,
        image: AppAssets.onboardingDiscover,
        illustration: _DiscoverIllustration(),
      ),
      _Slide(
        title: l10n.onboardingSlide2Title,
        body: l10n.onboardingSlide2Body,
        image: AppAssets.quranOnVelvet,
        illustration: _ListenIllustration(),
      ),
      _Slide(
        title: l10n.onboardingSlide3Title,
        body: l10n.onboardingSlide3Body,
        image: AppAssets.onboardingReflect,
        illustration: _ReflectIllustration(),
      ),
    ];
  }

  bool get _isLast => _index == _slides.length - 1;

  /// Mark onboarding as seen so the splash skips it next launch, then enter the
  /// app. Used by both "Get Started" and "Skip".
  Future<void> _finish() async {
    await sl<LocalStorageService>()
        .write(StorageKeys.onboardingComplete, true);
    Get.offAllNamed(AppRoutes.main);
  }

  void _next() {
    if (_isLast) {
      _finish();
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: GeometricBackground(
        child: SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: AppSpacing.screenPadding,
                  child: TextButton(
                    onPressed: _finish,
                    child: Text(l10n.onboardingSkip,
                        style: AppTypography.labelSemibold
                            .copyWith(color: AppColors.onSurfaceVariant)),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemCount: _slides.length,
                  itemBuilder: (context, i) => _SlideView(slide: _slides[i]),
                ),
              ),
              _dots(),
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: AppSpacing.screenPadding,
                child: GlowPrimaryButton(
                  label: _isLast ? l10n.onboardingGetStarted : l10n.onboardingNext,
                  trailingIcon: Icons.arrow_forward_rounded,
                  onPressed: _next,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (_index > 0)
                Padding(
                  padding: AppSpacing.screenPadding,
                  child: GhostGlassButton(
                    label: l10n.onboardingBack,
                    borderColor: AppColors.outlineVariant,
                    onPressed: () => _controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut),
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < _slides.length; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: i == _index ? 28 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i == _index ? AppColors.primary : AppColors.outlineVariant,
              borderRadius: AppRadii.pillRadius,
            ),
          ),
      ],
    );
  }
}

class _Slide {
  const _Slide({
    required this.title,
    required this.body,
    required this.image,
    required this.illustration,
  });
  final String title;
  final String body;
  final String image;
  final Widget illustration;
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Main background image (280px square per Stitch mockups)
          SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: AppRadii.cardRadius,
                  child: Image.asset(
                    slide.image,
                    width: 280,
                    height: 280,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 280,
                      height: 280,
                      color: AppColors.surfaceContainerHighest,
                      child: const Icon(Icons.image_not_supported, color: AppColors.onSurfaceVariant, size: 48),
                    ),
                  ),
                ),
                // Overlay illustration (phone frame, progress ring, light rays, etc.)
                slide.illustration,
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(slide.title,
              textAlign: TextAlign.center,
              style: AppTypography.headlineLgMobile),
          const SizedBox(height: AppSpacing.md),
          Text(slide.body,
              textAlign: TextAlign.center, style: AppTypography.bodyEn),
        ],
      ),
    ),
  );
  }
}

/// Discover slide illustration: Neumorphic phone frame with floating ornaments.
class _DiscoverIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Phone frame with neumorphic depth - frame around the 280x280 image
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  offset: const Offset(20, 20),
                  blurRadius: 60,
                ),
                // BoxShadow(
                //   color: Colors.white.withValues(alpha: 0.8),
                //   offset: const Offset(-20, -20),
                //   blurRadius: 60,
                // ),
              ],
            ),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
               // color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Container(), // Empty - main image rendered by _SlideView
              ),
            ),
          ),
          // Floating ornament top-right (matches Stitch: star with shimmer)
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(Icons.star_rounded, color: AppColors.primary, size: 22),
            ).animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 2000.ms, color: AppColors.primaryFixedDim),
          ),
          // Floating ornament bottom-left (mosque silhouette)
          Positioned(
            bottom: 20,
            left: 20,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(Icons.mosque_rounded, color: AppColors.primary, size: 22),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
                .moveY(begin: 0, end: -8, duration: 3000.ms, curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }
}

/// Listen slide illustration: Animated progress ring + cloud download + audio waves.
class _ListenIllustration extends StatefulWidget {
  @override
  State<_ListenIllustration> createState() => _ListenIllustrationState();
}

class _ListenIllustrationState extends State<_ListenIllustration>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Floating cloud download ornament (top-right) - matches Stitch design
          Positioned(
            top: 24,
            right: 16,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, math.sin(_controller.value * 2 * math.pi) * 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(36),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.secondary.withValues(alpha: 0.15),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.cloud_download_rounded,
                      color: AppColors.secondary, size: 36),
                ),
              ),
            ),
          ),
          // Audio wave bars (bottom-left) - matches Stitch
          Positioned(
            bottom: 24,
            left: 16,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _WaveBar(delay: 0.0, controller: _controller, index: 0),
                    _WaveBar(delay: 0.15, controller: _controller, index: 1),
                    _WaveBar(delay: 0.3, controller: _controller, index: 2),
                    _WaveBar(delay: 0.45, controller: _controller, index: 3),
                  ],
                ),
              ),
            ),
          ),
          // Progress ring (center overlay) - matches Stitch: circular progress with check
          Positioned.fill(
            child: Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) => SizedBox(
                  width: 96,
                  height: 96,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: _controller.value,
                        strokeWidth: 7,
                        backgroundColor: AppColors.surfaceContainerHighest.withValues(alpha: 0.4),
                        valueColor: const AlwaysStoppedAnimation(AppColors.secondary),
                      ),
                      const Icon(Icons.check_circle, color: AppColors.secondary, size: 44),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaveBar extends StatelessWidget {
  const _WaveBar({required this.delay, required this.controller, required this.index});
  final double delay;
  final AnimationController controller;
  final int index;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final phase = (controller.value * 2 * math.pi) + (delay * 2 * math.pi);
        final height = 8 + (math.sin(phase) + 1) / 2 * 18;
        return Container(
          width: 4,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: index.isEven ? AppColors.primary : AppColors.secondary,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}

/// Reflect slide illustration: Ethereal light rays shader effect (approximated).
class _ReflectIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Light rays effect (animated gradient overlay) - matches Stitch
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: AppRadii.cardRadius,
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Color(0x33006A39),
                    Color(0x33805200),
                    Colors.transparent,
                  ],
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
              .shimmer(duration: 4000.ms, color: Colors.white.withValues(alpha: 0.1)),
          ),
          // Floating glass ornaments - bookmark top-right
          Positioned(
            top: 36,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(Icons.bookmark_rounded, color: AppColors.primary, size: 26),
            ).animate(onPlay: (c) => c.repeat())
              .moveY(begin: 0, end: -12, duration: 3000.ms, curve: Curves.easeInOut),
          ),
          // Floating glass ornaments - auto_stories bottom-left
          Positioned(
            bottom: 36,
            left: 24,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.tertiary.withValues(alpha: 0.1),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(Icons.auto_stories_rounded, color: AppColors.tertiary, size: 26),
            ).animate(onPlay: (c) => c.repeat())
              .moveY(begin: 0, end: -12, duration: 4000.ms, delay: 1000.ms, curve: Curves.easeInOut),
          ),
          // Additional floating ornament - sparkles center-right
          Positioned(
            top: 120,
            right: 8,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              ),
              child: const Icon(Icons.auto_awesome_rounded, color: AppColors.tertiary, size: 22),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
              .moveY(begin: 0, end: -8, duration: 2500.ms, delay: 500.ms, curve: Curves.easeInOut),
          ),
        ],
      ),
    );
  }
}
