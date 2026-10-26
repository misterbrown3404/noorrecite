import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../controllers/prayer_times_controller.dart';
import 'worship_art.dart';

class NextPrayerCard extends StatelessWidget {
  const NextPrayerCard({
    super.key,
    required this.controller,
    this.showSchedule = true,
  });
  final PrayerTimesController controller;
  final bool showSchedule;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF194D48), Color(0xFF102F30)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(LucideIcons.clock, color: Color(0xFFE7D8AB), size: 16),
            SizedBox(width: 8),
            Text(
              'YOUR DAILY PRAYERS',
              style: TextStyle(
                color: Color(0xFFE7D8AB),
                letterSpacing: 1.5,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(
          () => Text(
            controller.hijriDate.value,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Finding your\nprayer times',
                        style: TextStyle(color: Colors.white, fontSize: 22),
                      ),
                      SizedBox(height: 14),
                      LinearProgressIndicator(color: Color(0xFFE7D8AB)),
                    ],
                  );
                }
                if (controller.error.value.isNotEmpty ||
                    controller.nextPrayer.value == null) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Make time\nfor prayer.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.error.value.isEmpty
                            ? 'Use your location for local times.'
                            : controller.error.value,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      TextButton(
                        onPressed: controller.loadPrayerTimes,
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFE7D8AB),
                        ),
                        child: const Text('Try location again'),
                      ),
                    ],
                  );
                }
                final next = controller.nextPrayer.value!;
                final current = controller.currentPrayer.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (current != null) ...[
                      Text(
                        controller.afterSunrise.value
                            ? 'LAST PRAYER'
                            : 'CURRENT PRAYER',
                        style: const TextStyle(
                          color: Color(0xFFE7D8AB),
                          fontSize: 10,
                          letterSpacing: 1.4,
                        ),
                      ),
                      Text(
                        current.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        current.formattedTime,
                        style: const TextStyle(
                          color: Color(0xFFE7D8AB),
                          fontSize: 17,
                        ),
                      ),
                      if (controller.afterSunrise.value)
                        const Text(
                          'Fajr ended at sunrise',
                          style: TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                      const SizedBox(height: 18),
                    ],
                    const Text(
                      'UP NEXT',
                      style: TextStyle(
                        color: Colors.white60,
                        fontSize: 10,
                        letterSpacing: 1.4,
                      ),
                    ),
                    Text(
                      next.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      next.formattedTime,
                      style: const TextStyle(
                        color: Color(0xFFE7D8AB),
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Obx(() {
                      final d = controller.remaining.value;
                      final seconds = d.inSeconds.clamp(0, 999999);
                      return Text(
                        'In ${seconds ~/ 3600}h ${(seconds ~/ 60) % 60}m ${seconds % 60}s',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      );
                    }),
                  ],
                );
              }),
            ),
            const WorshipArt(azkar: false, size: 82),
          ],
        ),
        if (showSchedule) ...[
          const SizedBox(height: 12),
          const Divider(color: Colors.white12),
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.prayerTimes),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: EdgeInsets.zero,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text('View today’s schedule')),
                Icon(LucideIcons.arrowRight, size: 18),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}
