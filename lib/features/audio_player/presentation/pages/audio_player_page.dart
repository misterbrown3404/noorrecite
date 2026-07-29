import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;

import '../../../../core/constants/app_assets.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/duration_format.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../downloads/presentation/controllers/download_controller.dart';
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
    // Resume after the first frame: this page is materialized lazily during a
    // build/layout pass, and resumeLastSession synchronously mutates reactive
    // state (queue/error) via setQueue. Mutating an observable while the
    // framework is still building would mark a live Obx dirty mid-build and
    // throw. Deferring to the post-frame callback runs it once building is done.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_audio.queue.isEmpty) {
        _audio.resumeLastSession();
      }
    });
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    ever(_audio.isPlaying, (playing) {
      if (!mounted) return;
      if (playing) {
        _waveformController.repeat();
      } else {
        _waveformController.stop();
      }
    });
  }

  @override
  void dispose() {
    _waveformController.dispose();
    super.dispose();
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        actions: [
          HeaderIconAction(
            icon: Icons.queue_music_rounded,
            onTap: () => _showQueueSheet(),
          ),
          HeaderIconAction(
            icon: Icons.download_outlined,
            onTap: () {
              final track = _audio.currentTrack;
              if (track != null) _onDownloadTap(track);
            },
          ),
        ],
      ),
      body: GeometricBackground(
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              const ParticleField(particleCount: 20),
              Padding(
                padding: AppSpacing.screenPadding,
                child: Column(
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
                    Expanded(child: Center(child: _artwork())),
                    const SizedBox(height: AppSpacing.lg),
                    _waveform(),
                    const SizedBox(height: AppSpacing.lg),
                    _scrubber(),
                    const SizedBox(height: AppSpacing.xl),
                    _transport(),
                    const SizedBox(height: AppSpacing.lg),
                    _actionDrawer(),
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
      builder: (_) => _QueueSheet(),
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
      return ParallaxWidget(
        maxRotationX: 6,
        maxRotationY: 6,
        maxTranslationX: 8,
        maxTranslationY: 8,
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
                        Container(
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _waveform() {
    return Obx(() {
      final playing = _audio.isPlaying.value;
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
      final pos = _audio.position.value;
      final dur = _audio.duration.value;
      final progress = dur.inMilliseconds > 0
          ? pos.inMilliseconds / dur.inMilliseconds
          : 0.0;

      return Column(
        children: [
          SizedBox(
            height: 24,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final trackWidth = constraints.maxWidth;
                return Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: progress.clamp(0.0, 1.0),
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            gradient: LinearGradient(
                              colors: [
                                AppColors.tertiary,
                                AppColors.tertiaryFixedDim,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.tertiary.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: (progress.clamp(0.0, 1.0) * trackWidth - 12).clamp(
                        0.0,
                        trackWidth - 24,
                      ),
                      top: 0,
                      child: GestureDetector(
                        onHorizontalDragUpdate: (d) {
                          if (dur.inMilliseconds == 0) return;
                          final newProgress =
                              ((progress + d.delta.dx / trackWidth).clamp(
                                0.0,
                                1.0,
                              ));
                          _audio.seek(
                            Duration(
                              milliseconds: (newProgress * dur.inMilliseconds)
                                  .round(),
                            ),
                          );
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.tertiary,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.tertiary.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(DurationFormat.clock(pos), style: AppTypography.labelSemibold),
                Text(DurationFormat.clock(dur), style: AppTypography.labelSemibold),
              ],
            ),
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
              Icons.shuffle_rounded,
              color: shuffle ? AppColors.primary : AppColors.onSurfaceVariant,
              size: 28,
            ),
          ),
          PressableScale(
            onTap: _audio.previous,
            child: NeuIconButton(
              icon: Icons.skip_previous_rounded,
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
                      playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: playing ? 40 : 48,
                    ),
            ),
          ),
          PressableScale(
            onTap: _audio.next,
            child: NeuIconButton(
              icon: Icons.skip_next_rounded,
              size: 56,
              onPressed: _audio.next,
            ),
          ),
          PressableScale(
            onTap: _audio.cycleRepeatMode,
            child: Icon(
              repeat == AudioRepeatMode.one
                  ? Icons.repeat_one_rounded
                  : Icons.repeat_rounded,
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
        (Icons.speed_rounded, '${speed}X', _audio.cycleSpeed),
        (Icons.queue_music_rounded, 'QUEUE', _showQueueSheet),
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

class _QueueSheet extends StatelessWidget {
  const _QueueSheet();

  @override
  Widget build(BuildContext context) {
    final audio = Get.find<AudioController>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Text('QUEUE', style: AppTypography.labelSemibold),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Obx(() {
              final queue = audio.queue;
              if (queue.isEmpty) {
                return const Center(child: Text('No surahs in queue'));
              }
              return ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: queue.length,
                itemBuilder: (context, index) {
                  final track = queue[index];
                  final isCurrent = index == audio.currentIndex.value;
                  return ListTile(
                    leading: Icon(
                      isCurrent
                          ? Icons.play_arrow_rounded
                          : Icons.circle_outlined,
                      color: isCurrent
                          ? AppColors.primary
                          : AppColors.onSurfaceVariant,
                      size: isCurrent ? 24 : 16,
                    ),
                    title: Text(
                      quran.getSurahName(track.surahNumber),
                      style: isCurrent
                          ? AppTypography.labelSemibold.copyWith(
                              color: AppColors.primary,
                            )
                          : AppTypography.labelSemibold,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      'Surah ${track.surahName} • ${track.reciterName}',
                      style: AppTypography.bodyEnSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    onTap: () {
                      audio.playAt(index);
                      Navigator.pop(context);
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
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
