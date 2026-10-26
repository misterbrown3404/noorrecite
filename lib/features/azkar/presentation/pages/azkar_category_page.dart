import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'dart:async';
import '../../../../core/widgets/qari_app_bar.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../../../audio_player/presentation/controllers/audio_controller.dart';
import '../../../../core/error/crash_reporter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../data/worship_repository.dart';
import 'worship_library.dart';

class AzkarCategoryPage extends StatefulWidget {
  const AzkarCategoryPage({super.key, required this.category});
  final AzkarCategory category;
  @override
  State<AzkarCategoryPage> createState() => _AzkarCategoryPageState();
}

class _AzkarCategoryPageState extends State<AzkarCategoryPage> {
  final Map<int, int> _counts = {};
  AudioController? _audio;
  StreamSubscription<PlayerState>? _stateSubscription;
  StreamSubscription<PlayerException>? _errorSubscription;
  String? _activeAsset;
  bool _loading = false;
  bool _playing = false;
  bool _showEnglish = true;
  bool _showPhonetics = true;

  void _reportPlaybackError(Object error) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Couldn’t play this recording. Please try again.'),
      ),
    );
  }

  Future<void> _play(DhikrAudio track) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      if (_audio == null) {
        _audio = Get.find<AudioController>();
        _stateSubscription = _audio!.player.playerStateStream.listen((state) {
          if (mounted) {
            setState(
              () => _playing =
                  _audio!.isAzkarPreview &&
                  state.playing &&
                  state.processingState != ProcessingState.completed,
            );
          }
        });
        _errorSubscription = _audio!.player.errorStream.listen(
          _reportPlaybackError,
        );
      }
      if (_audio!.isAzkarPreview && _activeAsset == track.asset && _playing) {
        await _audio!.player.pause();
      } else if (_audio!.isAzkarPreview &&
          _activeAsset == track.asset &&
          _audio!.player.processingState != ProcessingState.completed) {
        unawaited(
          _audio!.player.play().catchError(
            (Object error) => _reportPlaybackError(error),
          ),
        );
      } else {
        _activeAsset = track.asset;
        await _audio!.playAzkarPreview(
          track.asset,
          '${widget.category.englishTitle ?? widget.category.title} · ${track.label}',
        );
      }
    } catch (error) {
      _activeAsset = null;
      _reportPlaybackError(error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _errorSubscription?.cancel();
    final audio = _audio;
    if (audio != null) {
      unawaited(
        audio.endAzkarPreview().catchError((Object e, StackTrace s) {
          CrashReporter.instance.recordError(
            e,
            s,
            reason: 'restore Quran after Azkar',
          );
        }),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: QariAppBar(
      title: widget.category.displayTitle,
      subtitle: 'Azkar · Read & remember',
      actions: [
        IconButton(
          tooltip: 'Text and audio credits',
          icon: const Icon(LucideIcons.info),
          onPressed: () => showDialog<void>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('OpenDua credits'),
              content: const SingleChildScrollView(
                child: SelectableText(
                  'OpenDua dataset v0.0.4, by Ihsan Labs at the Human Development Fund. Based on Hisn al-Muslim by Sa’id ibn Ali ibn Wahf al-Qahtani. English and recitation transliterations: CC BY 4.0. Adapted to this app’s categories and reading layout. Category pronunciation guides are app-authored.\n\nhttps://opendua.org\nhttps://creativecommons.org/licenses/by/4.0/\n\nRecitation by Muhammad Jumah for OpenDua, release v0.0.2. Audio is covered by a separate licence:\nhttps://opendua.org/licence/audio',
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
    body: ListView.builder(
      padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
      itemCount: widget.category.entries.length + 1,
      itemBuilder: (context, itemIndex) {
        if (itemIndex == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.category.title,
                  textDirection: TextDirection.rtl,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (widget.category.transliteration != null)
                  Text(widget.category.transliteration!),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('English meaning'),
                      selected: _showEnglish,
                      onSelected: (v) => setState(() => _showEnglish = v),
                    ),
                    FilterChip(
                      label: const Text('Pronunciation'),
                      selected: _showPhonetics,
                      onSelected: (v) => setState(() => _showPhonetics = v),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
        final index = itemIndex - 1;
        final entry = widget.category.entries[index];
        final count = _counts[index] ?? 0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 18),
          child: WorshipTextCard(
            arabic: entry.text,
            transliteration: _showPhonetics ? entry.transliteration : null,
            meaning: _showEnglish ? entry.translation : null,
            title: '${index + 1} / ${widget.category.entries.length}',
            footer: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final track in entry.audio)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: OutlinedButton.icon(
                      onPressed: _loading ? null : () => _play(track),
                      icon: Icon(
                        _activeAsset == track.asset && _playing
                            ? LucideIcons.pause
                            : LucideIcons.play,
                      ),
                      label: Text(
                        _loading && _activeAsset == track.asset
                            ? 'Loading…'
                            : '${_activeAsset == track.asset && _playing ? 'Pause' : 'Listen'} · ${track.label}',
                      ),
                    ),
                  ),
                Text(
                  'Listed repetitions: ${entry.count}',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    setState(() => _counts[index] = count + 1);
                  },
                  icon: Icon(
                    count >= entry.count && entry.count > 0
                        ? LucideIcons.check
                        : LucideIcons.plus,
                  ),
                  label: Text('Count: $count · Tap to count'),
                ),
                if (count > 0)
                  TextButton(
                    onPressed: () => setState(() => _counts[index] = count - 1),
                    child: const Text('Undo last tap'),
                  ),
              ],
            ),
          ),
        );
      },
    ),
  );
}
