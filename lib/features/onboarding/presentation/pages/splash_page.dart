import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'welcome_art.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/storage/local_storage_service.dart';
import '../../../../core/storage/storage_keys.dart';
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
    _timer = Timer(Duration(milliseconds: seenOnboarding ? 900 : 1800), () {
      if (mounted) Get.offAllNamed(next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 360),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const FadeInUp(
                          child: WelcomeArt(icon: LucideIcons.bookOpen),
                        ),
                        const SizedBox(height: 24),
                        FadeInUp(
                          delay: const Duration(milliseconds: 200),
                          child: Column(
                            children: [
                              Text(
                                'QariVerse',
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontSize: 38,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -1.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'A little closer, every day.',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 36),
                        SizedBox(
                          width: 36,
                          child: LinearProgressIndicator(
                            minHeight: 3,
                            borderRadius: BorderRadius.circular(4),
                            value: MediaQuery.disableAnimationsOf(context)
                                ? 1
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
