import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/services/adhan_audio_service.dart';
import '../../../../core/services/notification_service.dart';
import '../controllers/prayer_times_controller.dart';

class PrayerSettingsCard extends StatelessWidget {
  const PrayerSettingsCard({super.key, required this.controller});
  final PrayerTimesController controller;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final reminders = NotificationService.instance;
    final adhan = AdhanAudioService.instance;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(
            () => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(LucideIcons.mapPin, color: colors.primary),
              title: Text(
                controller.locationLabel.value,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(controller.locationMessage.value),
            ),
          ),
          Obx(
            () => Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: controller.isRefreshing.value
                      ? null
                      : controller.loadPrayerTimes,
                  icon: const Icon(LucideIcons.locateFixed, size: 18),
                  label: Text(
                    controller.isRefreshing.value
                        ? 'Updating…'
                        : 'Update location',
                  ),
                ),
                if (controller.locationAction.value.isNotEmpty)
                  TextButton(
                    onPressed: () async {
                      final opened =
                          controller.locationAction.value == 'location'
                          ? await Geolocator.openLocationSettings()
                          : await Geolocator.openAppSettings();
                      if (!opened && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Open system settings to enable location for QariVerse.',
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Open settings'),
                  ),
              ],
            ),
          ),
          const Divider(height: 30),
          ValueListenableBuilder<String>(
            valueListenable: reminders.reminderStatus,
            builder: (_, status, _) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(LucideIcons.bellRing, color: colors.primary),
              title: const Text(
                'Prayer reminders',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(status),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.settings),
                icon: const Icon(LucideIcons.settings, size: 18),
                label: const Text('Reminder settings'),
              ),
              OutlinedButton(
                onPressed: () async {
                  try {
                    final allowed = await reminders.scheduleTestReminder();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            allowed
                                ? 'Test scheduled for about 10 seconds from now. Lock your screen to check delivery.'
                                : 'Notifications are blocked. Enable them in system settings.',
                          ),
                        ),
                      );
                    }
                  } catch (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Couldn’t schedule the test. Please try again.',
                          ),
                        ),
                      );
                    }
                  }
                },
                child: const Text('Test reminder'),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: adhan.isPlaying,
                builder: (_, playing, _) => OutlinedButton.icon(
                  onPressed: playing ? adhan.stop : adhan.play,
                  icon: Icon(
                    playing ? LucideIcons.square : LucideIcons.volume2,
                    size: 18,
                  ),
                  label: Text(playing ? 'Stop adhan' : 'Preview adhan'),
                ),
              ),
            ],
          ),
          ValueListenableBuilder<String>(
            valueListenable: adhan.error,
            builder: (_, error, _) => error.isEmpty
                ? const SizedBox.shrink()
                : Text(error, style: TextStyle(color: colors.error)),
          ),
          const SizedBox(height: 10),
          Text(
            'On iPhone, background reminders use the system notification sound. Tap the reminder to hear the full adhan. Device volume and Focus settings affect sound.',
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
