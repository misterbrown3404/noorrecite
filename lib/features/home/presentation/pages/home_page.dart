import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/routes/app_routes.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/widgets.dart';
import '../controllers/prayer_times_controller.dart';
import '../widgets/continue_listening_card.dart';
import '../widgets/daily_ayah_card.dart';
import '../widgets/greeting_header.dart';
import '../widgets/next_prayer_card.dart';
import '../widgets/popular_reciters.dart';

/// Home screen — a slim composition of the extracted section widgets. Each
/// section owns its own state subscriptions; this page only lays them out.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final prayerController = Get.find<PrayerTimesController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('QariVerse'),
        actions: [
          HeaderIconAction(
            icon: Icons.settings_rounded,
            onTap: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: GeometricBackground(
        showAura: true,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 120),
            children: [
              const SizedBox(height: AppSpacing.lg),
              const GreetingHeader(),
              const SizedBox(height: AppSpacing.xl),
              Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
                  children: [
                    NextPrayerCard(controller: prayerController),
                    const SizedBox(height: AppSpacing.lg),
                    const ContinueListeningCard(),
                    const SizedBox(height: AppSpacing.lg),
                    const DailyAyahCard(),
                    const SizedBox(height: AppSpacing.xl),
                  ],
                ),
              ),
              const PopularReciters(),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
