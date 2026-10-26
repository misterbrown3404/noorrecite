import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../playlists/presentation/playlists_sheet.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/duration_format.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../downloads/presentation/controllers/download_controller.dart';
import 'audio_picker_sheets.dart';
import 'sleep_timer_sheet.dart';
import '../../domain/entities/audio_track.dart';
import '../controllers/audio_controller.dart';

class AudioPlayerPage extends StatefulWidget {
  const AudioPlayerPage({super.key});

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveformController;
  late final AudioController _audio;
  late final DownloadController _downloads;
  late final Worker _playingWorker;
  late final Worker _bufferingWorker;

  static const _waveformBars = [
    _WaveBarConfig(delay: 0.1, minHeight: 12, maxHeight: 32),
    _WaveBarConfig(delay: 0.3, minHeight: 14, maxHeight: 32),
    _WaveBarConfig(delay: 0.2, minHeight: 10, maxHeight: 28),
    _WaveBarConfig(delay: 0.5, minHeight: 16, maxHeight: 32),
    _WaveBarConfig(delay: 0.4, minHeight: 12, maxHeight: 24),
    _WaveBarConfig(delay: 0.6, minHeight: 18, maxHeight: 30),
    _WaveBarConfig(delay: 0.1, minHeight: 14, maxHeight: 26),
    _WaveBarConfig(delay: 0.8, minHeight: 10, maxHeight: 22),
    _WaveBarConfig(delay: 0.2, minHeight: 12, maxHeight: 28),
    _WaveBarConfig(delay: 0.4, minHeight: 14, maxHeight: 32),
    _WaveBarConfig(delay: 0.3, minHeight: 10, maxHeight: 24),
    _WaveBarConfig(delay: 0.7, minHeight: 16, maxHeight: 30),
    _WaveBarConfig(delay: 0.1, minHeight: 12, maxHeight: 28),
  ];

  @override
  void initState() {
    super.initState();
    _audio = Get.find<AudioController>();
    _downloads = Get.find<DownloadController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_audio.queue.isEmpty) {
        _audio.resumeLastSession();
      }
    });
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _bufferingWorker = ever(_audio.isBuffering, (_) {
      if (mounted) _syncMotion();
    });
    _playingWorker = ever(_audio.isPlaying, (playing) {
      if (!mounted) return;
      _syncMotion();
    });
  }

  void _syncMotion() {
    if (_audio.isPlaying.value &&
        !_audio.isBuffering.value &&
        !MediaQuery.disableAnimationsOf(context)) {
      _waveformController.repeat();
    } else {
      _waveformController.stop();
      _waveformController.value = 0;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotion();
  }

  @override
  void dispose() {
    _playingWorker.dispose();
    _bufferingWorker.dispose();
    _waveformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final actionStyle = IconButton.styleFrom(
      foregroundColor: colors.primary,
      backgroundColor: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Recitation',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: -.3,
          ),
        ),
        centerTitle: false,
        titleSpacing: 8,
        leadingWidth: 56,
        leading: Navigator.of(context).canPop()
            ? Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Center(
                  child: IconButton(
                    tooltip: 'Back',
                    style: actionStyle,
                    icon: const Icon(LucideIcons.chevronDown),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                ),
              )
            : null,
        toolbarHeight: 76,
        actionsPadding: const EdgeInsets.only(right: 8),
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        shape: const RoundedRectangleBorder(),
        actions: [
          IconButton(
            style: actionStyle,
            tooltip: 'Change reciter',
            icon: const Icon(LucideIcons.speech),
            onPressed: _showReciterSheet,
          ),
          Obx(() {
            final track = _audio.currentTrack;
            final downloading =
                track != null && _downloads.isDownloading(track.id);
            final downloaded =
                track != null && _downloads.isDownloaded(track.id);
            return IconButton(
              style: actionStyle,
              tooltip: downloading
                  ? 'Cancel download'
                  : downloaded
                  ? 'Remove download'
                  : 'Download',
              onPressed: track == null ? null : () => _onDownloadTap(track),
              icon: downloading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CircularProgressIndicator(
                            value: (_downloads.progress[track.id] ?? 0) > 0
                                ? _downloads.progress[track.id]
                                : null,
                            strokeWidth: 2,
                          ),
                          const Icon(LucideIcons.x, size: 14),
                        ],
                      ),
                    )
                  : Icon(
                      downloaded ? LucideIcons.download : LucideIcons.download,
                    ),
            );
          }),
          PopupMenuButton<String>(
            tooltip: 'Playback options',
            icon: const Icon(LucideIcons.ellipsis),
            onSelected: (action) {
              switch (action) {
                case 'playlists':
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    builder: (_) => const PlaylistsSheet(),
                  );
                case 'sleep':
                  showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    showDragHandle: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(32),
                      ),
                    ),
                    builder: (_) => SleepTimerSheet(audio: _audio),
                  );
              }
            },
            itemBuilder: (_) {
              return [
                const PopupMenuItem(
                  value: 'playlists',
                  child: Text('Playlists'),
                ),
                const PopupMenuItem(value: 'sleep', child: Text('Sleep timer')),
              ];
            },
          ),
        ],
      ),
      body: GeometricBackground(
        child: SafeArea(
          bottom: true,
          child: Stack(
            children: [
              Padding(
                padding: AppSpacing.screenPadding,
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 150),
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Obx(() {
                      final msg = _audio.error.value;
                      if (msg.isEmpty) return const SizedBox.shrink();
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: AppSpacing.md),
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.12),
                          borderRadius: AppRadii.cardRadius,
                        ),
                        child: Text(
                          msg,
                          style: AppTypography.bodyEnSm.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      );
                    }),
                    Center(child: _artwork()),
                    const SizedBox(height: AppSpacing.lg),
                    _waveform(),
                    const SizedBox(height: AppSpacing.lg),
                    _scrubber(),
                    const SizedBox(height: AppSpacing.xl),
                    _transport(),
                    const SizedBox(height: AppSpacing.lg),
                    _actionDrawer(),
                    Obx(
                      () => _audio.sleepMinutes.value == 0
                          ? const SizedBox.shrink()
                          : Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                'Sleep timer · ${_audio.sleepMinutes.value} min remaining',
                              ),
                            ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showQueueSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AudioQueueSheet(),
    );
  }

  /// Reciter picker: lists every reciter, scrollable, and starts playback of
  /// the current surah with whichever reciter is tapped.
  void _showReciterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReciterPickerSheet(
        currentSurahNumber: _audio.currentTrack?.surahNumber,
      ),
    );
  }

  /// Download the current surah, or offer to remove it if already saved.
  void _onDownloadTap(AudioTrack track) {
    if (_downloads.isDownloading(track.id)) {
      _downloads.cancelDownload(track.id);
      return;
    }
    if (_downloads.isDownloaded(track.id)) {
      Get.dialog(
        AlertDialog(
          title: const Text('Remove download'),
          content: Text('Delete the offline copy of ${track.surahName}?'),
          actions: [
            TextButton(onPressed: Get.back, child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                Get.back();
                _downloads.remove(track.id);
              },
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      return;
    }
    _downloads.downloadTrack(track);
  }

  Widget _artwork() {
    return Obx(() {
      final track = _audio.currentTrack;
      return AnimatedBuilder(
        animation: _waveformController,
        builder: (_, child) => Transform.scale(
          scale: 1 + .008 * math.sin(_waveformController.value * 2 * math.pi),
          child: child,
        ),
        child: RepaintBoundary(
          child: AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: AppRadii.cardRadius,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
                border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
              ),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: AppRadii.cardRadius,
                    child: Image.asset(
                      AppAssets.quranOnVelvet,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: AppRadii.cardRadius,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),
                  if (track != null)
                    Positioned(
                      left: AppSpacing.lg,
                      right: AppSpacing
                          .lg, // bound the width so it can't overflow the card
                      bottom: AppSpacing.lg,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            quran.getSurahName(track.surahNumber),
                            style: AppTypography.headlineLgMobile.copyWith(
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.goldGradient,
                                borderRadius: AppRadii.pillRadius,
                              ),
                              child: Text(
                                track.reciterName.toUpperCase(),
                                style: AppTypography.labelCaps.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 1.5,
                                ),
                                maxLines:
                                    1, // FittedBox handles overflow now, no ellipsis needed
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
        ),
      );
    });
  }

  Widget _waveform() {
    return Obx(() {
      final playing =
          _audio.isPlaying.value && !MediaQuery.disableAnimationsOf(context);
      return SizedBox(
        height: 64,
        child: AnimatedBuilder(
          animation: _waveformController,
          builder: (context, _) => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (int i = 0; i < _waveformBars.length; i++)
                _WaveBar(
                  config: _waveformBars[i],
                  controller: _waveformController,
                  isPlaying: playing,
                  index: i,
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _scrubber() {
    return Obx(() {
      final total = _audio.duration.value.inMilliseconds;
      final position = _audio.position.value.inMilliseconds;
      return Column(
        children: [
          Slider(
            value: total > 0 ? (position / total).clamp(0.0, 1.0) : 0,
            onChanged: total > 0
                ? (value) => _audio.seek(
                    Duration(milliseconds: (value * total).round()),
                  )
                : null,
            semanticFormatterCallback: (value) => DurationFormat.clock(
              Duration(milliseconds: (value * total).round()),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(DurationFormat.clock(_audio.position.value)),
              Text(DurationFormat.clock(_audio.duration.value)),
            ],
          ),
        ],
      );
    });
  }

  Widget _transport() {
    return Obx(() {
      final playing = _audio.isPlaying.value;
      final buffering = _audio.isBuffering.value;
      final repeat = _audio.repeatMode.value;
      final shuffle = _audio.isShuffling.value;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PressableScale(
            onTap: _audio.toggleShuffle,
            child: Icon(
              LucideIcons.shuffle,
              color: shuffle ? AppColors.primary : AppColors.onSurfaceVariant,
              size: 28,
            ),
          ),
          PressableScale(
            onTap: _audio.previous,
            child: NeuIconButton(
              icon: LucideIcons.skipBack,
              size: 56,
              onPressed: _audio.previous,
            ),
          ),
          PressableScale(
            onTap: _audio.togglePlayPause,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                gradient: AppColors.tealEmeraldGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: buffering
                  ? const Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(
                      playing ? LucideIcons.pause : LucideIcons.play,
                      color: Colors.white,
                      size: playing ? 40 : 48,
                    ),
            ),
          ),
          PressableScale(
            onTap: _audio.next,
            child: NeuIconButton(
              icon: LucideIcons.skipForward,
              size: 56,
              onPressed: _audio.next,
            ),
          ),
          PressableScale(
            onTap: _audio.cycleRepeatMode,
            child: Icon(
              repeat == AudioRepeatMode.one
                  ? LucideIcons.repeat1
                  : LucideIcons.repeat,
              color: repeat != AudioRepeatMode.off
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
              size: 28,
            ),
          ),
        ],
      );
    });
  }

  Widget _actionDrawer() {
    return Obx(() {
      final speed = _audio.speed.value;
      final actions = [
        (LucideIcons.gauge, '${speed}X', _audio.cycleSpeed),
        (LucideIcons.listMusic, 'QUEUE', _showQueueSheet),
      ];
      return Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainer.withValues(alpha: 0.3),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              offset: const Offset(0, -4),
              blurRadius: 16,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.5),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final (icon, label, onTap) in actions)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PressableScale(
                    onTap: onTap,
                    child: Icon(icon, color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(label, style: AppTypography.labelCaps),
                ],
              ),
          ],
        ),
      );
    });
  }
}

class _WaveBarConfig {
  const _WaveBarConfig({
    required this.delay,
    required this.minHeight,
    required this.maxHeight,
  });
  final double delay;
  final double minHeight;
  final double maxHeight;
}

class _WaveBar extends StatelessWidget {
  const _WaveBar({
    required this.config,
    required this.controller,
    required this.isPlaying,
    required this.index,
  });
  final _WaveBarConfig config;
  final AnimationController controller;
  final bool isPlaying;
  final int index;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        if (!isPlaying) {
          return Container(
            width: 4,
            height: config.minHeight,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: index.isEven
                  ? AppColors.primary
                  : AppColors.primaryFixedDim,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }
        final phase =
            (controller.value * 2 * math.pi) + (config.delay * 2 * math.pi);
        final t = (math.sin(phase) + 1) / 2;
        final height =
            config.minHeight + t * (config.maxHeight - config.minHeight);
        return Container(
          width: 4,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: index.isEven ? AppColors.primary : AppColors.primaryFixedDim,
            borderRadius: BorderRadius.circular(2),
          ),
        );
      },
    );
  }
}
