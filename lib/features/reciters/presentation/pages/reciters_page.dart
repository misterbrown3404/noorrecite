import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/widgets.dart';
import '../../../audio_player/presentation/controllers/audio_controller.dart';
import '../controllers/reciter_controller.dart';

class RecitersPage extends StatelessWidget {
  const RecitersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ReciterController>();
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reciters',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        titleSpacing: 20,
        toolbarHeight: 84,
        foregroundColor: colors.onSurface,
        backgroundColor: colors.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: TextField(
              onChanged: (value) => controller.searchQuery.value = value,
              decoration: InputDecoration(
                hintText: 'Search reciters',
                prefixIcon: const Icon(LucideIcons.search),
                filled: true,
                fillColor: colors.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.error.value.isNotEmpty) {
                return ErrorStateView(
                  message: controller.error.value,
                  onRetry: controller.fetchReciters,
                );
              }
              final reciters = controller.filteredReciters;
              if (reciters.isEmpty) {
                return const Center(child: Text('No reciters found'));
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 160),
                itemCount: reciters.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final reciter = reciters[index];
                  final portrait = AppAssets.reciterImage(reciter.id);
                  return Material(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(26),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        Get.find<AudioController>().playReciter(
                          reciter,
                          startSurahNumber: 1,
                        );
                        Get.toNamed(AppRoutes.audioPlayer);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SizedBox(
                                width: 80,
                                height: 100,
                                child: portrait == null
                                    ? ColoredBox(
                                        color: colors.primaryContainer,
                                        child: Icon(
                                          LucideIcons.userRound,
                                          color: colors.onSurfaceVariant,
                                          size: 40,
                                        ),
                                      )
                                    : Image.asset(
                                        portrait,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Icon(
                                          LucideIcons.userRound,
                                          color: colors.onSurfaceVariant,
                                          size: 40,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reciter.name,
                                    style: TextStyle(
                                      color: colors.onSurface,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if ((reciter.primaryMoshaf?.name ?? '')
                                      .isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      reciter.primaryMoshaf!.name,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: colors.onSurfaceVariant,
                                        fontSize: 12,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 14),
                                  Align(
                                    alignment: AlignmentDirectional.centerEnd,
                                    child: CircleAvatar(
                                      radius: 19,
                                      backgroundColor: colors.primary,
                                      child: Icon(
                                        LucideIcons.play,
                                        color: colors.onPrimary,
                                        size: 24,
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
