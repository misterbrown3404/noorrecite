import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../network/connectivity_controller.dart';
import '../theme/app_theme.dart';

/// A slim, animated "You're offline" banner driven by [ConnectivityController].
///
/// Mounted once at the app root (below the status bar, above all routes) so it
/// covers every screen without each page opting in. Collapses to zero height
/// when online, so it costs nothing visually while connected.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // The controller may not be registered in tests / non-app harnesses.
    if (!Get.isRegistered<ConnectivityController>()) {
      return const SizedBox.shrink();
    }
    final connectivity = Get.find<ConnectivityController>();

    return Obx(() {
      final online = connectivity.isOnline.value;
      return AnimatedSize(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        child: online
            ? const SizedBox(width: double.infinity)
            : Material(
                color: AppColors.error,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.sm,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          color: AppColors.onError,
                          size: 16,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Flexible(
                          child: Text(
                            "You're offline — showing saved content",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.labelSemibold.copyWith(
                              color: AppColors.onError,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      );
    });
  }
}
