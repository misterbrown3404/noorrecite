import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/audio_controller.dart';

class SleepTimerSheet extends StatefulWidget {
  const SleepTimerSheet({super.key, required this.audio});
  final AudioController audio;
  @override
  State<SleepTimerSheet> createState() => _SleepTimerSheetState();
}

class _SleepTimerSheetState extends State<SleepTimerSheet> {
  int _minutes = 30;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF194D48), Color(0xFF102F30)],
                ),
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                children: [
                  const Icon(
                    LucideIcons.moon,
                    size: 38,
                    color: Color(0xFFE7D8AB),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Rest easy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                    () => Text(
                      widget.audio.sleepMinutes.value > 0
                          ? '${widget.audio.sleepMinutes.value} min remaining'
                          : 'Let your recitation pause automatically.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Sleep timer', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final minutes in [15, 30, 45, 60])
                  ChoiceChip(
                    label: Text('$minutes min'),
                    selected: _minutes == minutes,
                    showCheckmark: false,
                    selectedColor: colors.primaryContainer,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    onSelected: (_) => setState(() => _minutes = minutes),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              onPressed: () {
                widget.audio.setSleepTimer(_minutes);
                Navigator.pop(context);
              },
              icon: const Icon(LucideIcons.moon, size: 20),
              label: Text('Set timer · $_minutes min'),
            ),
            Obx(
              () => widget.audio.sleepMinutes.value > 0
                  ? TextButton(
                      onPressed: () {
                        widget.audio.setSleepTimer(0);
                        Navigator.pop(context);
                      },
                      child: const Text('Turn off timer'),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
