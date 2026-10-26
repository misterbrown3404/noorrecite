import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../home/presentation/widgets/worship_art.dart';

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});
  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  static const _phrases = [
    ('Tasbih', 'سُبْحَانَ اللَّهِ', 'SubhanAllah', 'Glory be to Allah.'),
    (
      'Tahmid',
      'الْحَمْدُ لِلَّهِ',
      'Alhamdulillah',
      'All praise belongs to Allah.',
    ),
    ('Takbir', 'اللَّهُ أَكْبَرُ', 'Allahu Akbar', 'Allah is the Greatest.'),
    (
      'Istighfar',
      'أَسْتَغْفِرُ اللَّهَ',
      'Astaghfirullah',
      'I seek forgiveness from Allah.',
    ),
  ];
  final _counts = List.filled(_phrases.length, 0);
  int _selected = 0;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final phrase = _phrases[_selected];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasbih counter'),
        actions: [
          IconButton(
            tooltip: 'Reset current counter',
            onPressed: _counts[_selected] == 0
                ? null
                : () async {
                    final reset = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset this counter?'),
                        content: Text(
                          'Your ${phrase.$1} count will return to zero.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Keep count'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                    if (reset == true && mounted) {
                      setState(() => _counts[_selected] = 0);
                    }
                  },
            icon: const Icon(LucideIcons.rotateCcw),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
        children: [
          Text(
            'A moment of remembrance',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a dhikr and go at your own pace.',
            style: TextStyle(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (var i = 0; i < _phrases.length; i++)
                ChoiceChip(
                  label: Text(_phrases[i].$1),
                  selected: _selected == i,
                  onSelected: (_) => setState(() => _selected = i),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              children: [
                const WorshipArt(azkar: true, size: 140),
                const SizedBox(height: 16),
                AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 250),
                  child: Column(
                    key: ValueKey(_selected),
                    children: [
                      Text(
                        phrase.$2,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 36,
                          height: 1.7,
                          color: colors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        phrase.$3,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        phrase.$4,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Semantics(
                  liveRegion: true,
                  child: Text(
                    '${_counts[_selected]}',
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ),
                const Text(
                  'THIS SESSION',
                  style: TextStyle(fontSize: 10, letterSpacing: 1.8),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.all(18),
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      setState(() => _counts[_selected]++);
                    },
                    icon: const Icon(LucideIcons.plus),
                    label: const Text('Tap to count'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'A free-count remembrance session. Counts are kept while this screen is open; no prescribed repetition target is set.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.onSurfaceVariant,
              fontSize: 12,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
