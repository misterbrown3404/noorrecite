import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/main_shell_controller.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../playlists/presentation/playlists_sheet.dart';
import '../../../quran_reader/presentation/controllers/surah_controller.dart';
import '../controllers/bookmarks_controller.dart';

class BookmarksPage extends StatelessWidget {
  const BookmarksPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bookmarks = Get.find<BookmarksController>();
    final quran = Get.find<SurahController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Saved',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
        ),
        centerTitle: false,
        toolbarHeight: 80,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        shape: const RoundedRectangleBorder(),
      ),
      body: Obx(
        () => CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Material(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(28),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Get.find<MainShellController>().select(1),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Continue reading',
                                      style: TextStyle(
                                        color: colors.onPrimaryContainer,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      quran.lastRead.value?.surahName ??
                                          'Your next quiet moment',
                                      style: TextStyle(
                                        color: colors.onPrimaryContainer,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      quran.lastRead.value == null
                                          ? 'Open the Quran'
                                          : 'Verse ${quran.lastRead.value!.ayah}',
                                      style: TextStyle(
                                        color: colors.onPrimaryContainer,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                LucideIcons.bookOpen,
                                size: 38,
                                color: colors.onPrimaryContainer,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _CollectionLink(
                            label: 'Playlists',
                            icon: LucideIcons.listMusic,
                            onTap: () => showModalBottomSheet<void>(
                              context: context,
                              isScrollControlled: true,
                              showDragHandle: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(32),
                                ),
                              ),
                              builder: (_) => const PlaylistsSheet(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CollectionLink(
                            label: 'Offline',
                            icon: LucideIcons.circleCheck,
                            onTap: () => Get.toNamed(AppRoutes.downloadCenter),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Bookmarks',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Chip(
                          label: Text('${bookmarks.count}'),
                          side: BorderSide.none,
                          backgroundColor: colors.surfaceContainerLow,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (bookmarks.bookmarks.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        LucideIcons.library,
                        size: 54,
                        color: colors.primary,
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Keep a verse close',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Bookmark an ayah while reading to find it here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: colors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 20),
                      FilledButton(
                        onPressed: () =>
                            Get.find<MainShellController>().select(1),
                        child: const Text('Explore Quran'),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList.builder(
                  itemCount: bookmarks.bookmarks.length,
                  itemBuilder: (context, index) {
                    final bookmark = bookmarks.bookmarks[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: .3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                LucideIcons.bookmark,
                                color: colors.primary,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  bookmark.reference.isNotEmpty
                                      ? bookmark.reference
                                      : '${bookmark.surahName} · ${bookmark.ayah}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              IconButton(
                                tooltip: bookmark.isFavorite
                                    ? 'Remove favorite'
                                    : 'Favorite',
                                onPressed: () =>
                                    bookmarks.toggleFavorite(bookmark.id),
                                icon: Icon(
                                  bookmark.isFavorite
                                      ? LucideIcons.heart
                                      : LucideIcons.heart,
                                  color: colors.primary,
                                ),
                              ),
                              IconButton(
                                tooltip: 'Remove bookmark',
                                icon: const Icon(LucideIcons.trash2, size: 20),
                                onPressed: () async {
                                  final remove = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Remove bookmark?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Keep'),
                                        ),
                                        FilledButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Remove'),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (remove == true) {
                                    bookmarks.remove(bookmark.id);
                                  }
                                },
                              ),
                            ],
                          ),
                          if (bookmark.arabic.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text(
                              bookmark.arabic,
                              textDirection: TextDirection.rtl,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 24,
                                height: 1.8,
                              ),
                            ),
                          ],
                          if (bookmark.translation.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text(
                              bookmark.translation,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 210)),
          ],
        ),
      ),
    );
  }
}

class _CollectionLink extends StatelessWidget {
  const _CollectionLink({
    required this.label,
    required this.icon,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: colors.primary, size: 28),
              const SizedBox(height: 16),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
