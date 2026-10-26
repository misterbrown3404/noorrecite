import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/widgets/qari_app_bar.dart';
import '../widgets/prayer_settings_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/prayer_times_controller.dart';
import '../widgets/next_prayer_card.dart';

class PrayerTimesPage extends StatelessWidget {
  const PrayerTimesPage({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PrayerTimesController>();
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: QariAppBar(
        title: 'Prayer times',
        subtitle: 'Salah · Your daily rhythm',
        actions: [
          IconButton(
            tooltip: 'Prayer notification settings',
            onPressed: () => Get.toNamed(AppRoutes.settings),
            icon: const Icon(LucideIcons.settings),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadPrayerTimes,
        child: ListView(
          padding: const EdgeInsets.all(22),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Text(
              DateFormat('EEEE, d MMMM').format(DateTime.now()),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 18),
            NextPrayerCard(controller: controller, showSchedule: false),

            const SizedBox(height: 24),
            Text(
              'Today’s schedule',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Obx(
              () => Container(
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: .35),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    for (final p in controller.allPrayerTimes)
                      Container(
                        color: p.isNext
                            ? colors.primaryContainer.withValues(alpha: .6)
                            : null,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              switch (p.name) {
                                'Fajr' => LucideIcons.sunrise,
                                'Sunrise' => LucideIcons.sun,
                                'Dhuhr' => LucideIcons.sun,
                                'Asr' => LucideIcons.cloudSun,
                                'Maghrib' => LucideIcons.mountain,
                                _ => LucideIcons.moon,
                              },
                              color: colors.primary,
                              size: 22,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: TextStyle(
                                      color: colors.onSurface,
                                      fontWeight: p.isNext
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  if (p.isNext || p.name == 'Sunrise')
                                    Text(
                                      p.isNext ? 'Up next' : 'Sunrise',
                                      style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                        fontSize: 11,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: Text(
                                p.formattedTime,
                                textAlign: TextAlign.end,
                                style: TextStyle(
                                  color: colors.onSurface,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                shape: const Border(),
                collapsedShape: const Border(),
                leading: Icon(
                  LucideIcons.slidersHorizontal,
                  color: colors.primary,
                ),
                title: const Text('Location & reminders'),
                subtitle: Obx(() => Text(controller.locationLabel.value)),
                childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 12),
                children: [PrayerSettingsCard(controller: controller)],
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Calculated for your device location using Muslim World League · Shafi. Times are shown in your device’s local time zone.',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 12,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
