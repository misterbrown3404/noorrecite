import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';

/// Splash screen (mockups: splash_screen_1 / _2): a glowing gemstone tile with
/// the wordmark, auto-advancing to onboarding after a brief beat.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // After the splash beat, go to onboarding only the first time; on every
    // later launch the flag is set and we jump straight to the main shell.
    final seenOnboarding =
        sl<LocalStorageService>().read<bool>(StorageKeys.onboardingComplete) ??
            false;
    final next = seenOnboarding ? AppRoutes.main : AppRoutes.onboarding;
    _timer = Timer(
      const Duration(milliseconds: 2200),
      () => Get.offAllNamed(next),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GeometricBackground(
        showAura: true,
        child: Stack(
          children: [
            const ParticleField(particleCount: 35),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PulseGlow(
                    color: AppColors.primaryFixedDim,
                    child: Floating(
                      amplitude: 6,
                      child: Container(
                        width: 210,
                        height: 260,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadii.xl),
                          boxShadow: AppShadows.card,
                          image: const DecorationImage(
                            image: AssetImage(AppAssets.splashQuran),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: Column(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFFFFDDB5), Color(0xFFFFB957), Color(0xFF805200)],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ).createShader(bounds),
                          child: Text('QariVerse',
                              style: AppTypography.headlineLg.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Padding(
                          padding: AppSpacing.screenPadding,
                          child: Text(
                            'Experience the Divine Echoes in a Modern Sanctuary',
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyEn,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        Text('BISMILLAH',
                            style: AppTypography.labelCaps.copyWith(
                                letterSpacing: 3, color: AppColors.outline)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
