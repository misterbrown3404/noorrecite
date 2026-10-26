import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../app/main_shell_controller.dart';
import '../../../core/widgets/animations.dart';
import 'reading_progress_controller.dart';

class ReadingJourneyCard extends StatelessWidget {
  const ReadingJourneyCard({super.key, this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReadingProgressController>();
    return Obx(() {
      final progress = controller.progress.value;
      final count = progress.count(DateTime.now());
      final fraction = (count / progress.dailyGoal).clamp(0.0, 1.0);
      if (compact) {
        final colors = Theme.of(context).colorScheme;
        return Material(
          color: colors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(22),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Your daily reading',
                        style: TextStyle(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Set daily verse goal',
                      onPressed: () => _goalSheet(context, controller),
                      icon: const Icon(LucideIcons.slidersHorizontal, size: 19),
                    ),
                  ],
                ),
                Text(
                  '$count of ${progress.dailyGoal} verses · ${progress.streak(DateTime.now())} day streak',
                  style: TextStyle(
                    color: colors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                LinearProgressIndicator(
                  value: fraction,
                  minHeight: 4,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => Get.find<MainShellController>().select(1),
                  icon: const Icon(LucideIcons.arrowRight, size: 18),
                  label: Text(
                    count >= progress.dailyGoal
                        ? 'Read more'
                        : 'Continue reading',
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6455DF), Color(0xFF392C87)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6455DF).withValues(alpha: .25),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'YOUR READING JOURNEY',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Set daily verse goal',
                  onPressed: () => _goalSheet(context, controller),
                  icon: const Icon(
                    LucideIcons.slidersHorizontal,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        count >= progress.dailyGoal
                            ? 'Beautiful consistency.'
                            : 'Make space for Quran.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '$count of ${progress.dailyGoal} verses today',
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${progress.streak(DateTime.now())} day reading streak',
                        style: const TextStyle(
                          color: Color(0xFFD6F58A),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 68,
                  height: 68,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: fraction),
                    duration: MediaQuery.disableAnimationsOf(context)
                        ? Duration.zero
                        : const Duration(milliseconds: 700),
                    builder: (_, value, _) => Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox.expand(
                          child: CircularProgressIndicator(
                            value: value,
                            strokeWidth: 6,
                            color: const Color(0xFFD6F58A),
                            backgroundColor: Colors.white24,
                            strokeCap: StrokeCap.round,
                          ),
                        ),
                        const Icon(
                          LucideIcons.bookOpen,
                          color: Colors.white,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            PressableScale(
              onTap: () => Get.find<MainShellController>().select(1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6F58A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Let’s read',
                      style: TextStyle(
                        color: Color(0xFF27213B),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 20),
                    Icon(
                      LucideIcons.arrowRight,
                      size: 19,
                      color: Color(0xFF27213B),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _goalSheet(BuildContext context, ReadingProgressController controller) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Small steps. Lasting habits.',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text(
                'Choose your daily verse goal. Mark verses read in the reader to track your progress.',
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                children: [
                  for (final goal in [5, 10, 20, 50])
                    ActionChip(
                      label: Text('$goal verses'),
                      onPressed: () async {
                        await controller.setGoal(goal);
                        if (context.mounted) Navigator.pop(context);
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
