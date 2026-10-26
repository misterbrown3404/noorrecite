import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../app/main_shell_controller.dart';
import 'reading_progress_controller.dart';
import 'reading_journey_card.dart';

class ReadingStatisticsPage extends StatelessWidget {
  const ReadingStatisticsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReadingProgressController>();
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading statistics'),
        centerTitle: false,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        shape: const RoundedRectangleBorder(),
      ),
      body: Obx(() {
        final progress = controller.progress.value;
        final now = DateTime.now();
        final days = List.generate(
          7,
          (i) => DateTime(now.year, now.month, now.day - 6 + i),
        );
        final counts = days.map(progress.count).toList();
        final peak = counts.fold<int>(1, (a, b) => a > b ? a : b);
        final total = counts.fold<int>(0, (a, b) => a + b);
        final unique = progress.days.values.expand((v) => v).toSet().length;
        return ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    LucideIcons.chartNoAxesCombined,
                    color: colors.onPrimaryContainer,
                    size: 30,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '${progress.streak(now)} day streak',
                    style: TextStyle(
                      color: colors.onPrimaryContainer,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$unique unique verses marked read',
                    style: TextStyle(color: colors.onPrimaryContainer),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const ReadingJourneyCard(compact: true),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Last 7 days',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$total verses marked read',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      for (var i = 0; i < 7; i++)
                        Expanded(
                          child: Semantics(
                            label:
                                '${DateFormat('EEEE, d MMM').format(days[i])}: ${counts[i]} verses',
                            child: ExcludeSemantics(
                              child: Column(
                                children: [
                                  Text(
                                    '${counts[i]}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    height: 110,
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: TweenAnimationBuilder<double>(
                                        tween: Tween(
                                          begin: 0,
                                          end: counts[i] / peak,
                                        ),
                                        duration:
                                            MediaQuery.disableAnimationsOf(
                                              context,
                                            )
                                            ? Duration.zero
                                            : const Duration(milliseconds: 600),
                                        builder: (_, value, _) => Container(
                                          width: 20,
                                          height: 4 + value * 106,
                                          decoration: BoxDecoration(
                                            color: i == 6
                                                ? colors.primary
                                                : colors.primary.withValues(
                                                    alpha: .35,
                                                  ),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    DateFormat('E').format(days[i]),
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Based on verses you mark read in the Quran reader.',
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () {
                Get.back();
                Get.find<MainShellController>().select(1);
              },
              icon: const Icon(LucideIcons.bookOpen),
              label: const Text('Read Quran'),
            ),
          ],
        );
      }),
    );
  }
}
