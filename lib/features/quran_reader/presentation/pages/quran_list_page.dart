import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;
import '../../../../app/routes/app_routes.dart';
import '../../../../core/widgets/widgets.dart';
import '../../domain/entities/surah.dart';
import '../controllers/surah_controller.dart';

class QuranListPage extends StatefulWidget {
  const QuranListPage({super.key});
  @override
  State<QuranListPage> createState() => _QuranListPageState();
}

class _QuranListPageState extends State<QuranListPage> {
  final _search = TextEditingController();
  int _juz = 1;
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SurahController>();
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Quran',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        toolbarHeight: 64,
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: const RoundedRectangleBorder(),
        actions: [
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(LucideIcons.settings),
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
      body: Obx(() {
        var surahs = controller.filteredSuwar;
        if (controller.filter.value == SurahFilter.juz) {
          final ids = quran.getSurahAndVersesFromJuz(_juz).keys.toSet();
          surahs = surahs.where((s) => ids.contains(s.id)).toList();
        }
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _search,
                      onChanged: (value) {
                        controller.searchQuery.value = value;
                        setState(() {});
                      },
                      decoration: InputDecoration(
                        hintText: 'Search surahs',
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
                        prefixIcon: const Icon(LucideIcons.search),
                        suffixIcon: _search.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear search',
                                icon: const Icon(LucideIcons.x),
                                onPressed: () {
                                  _search.clear();
                                  controller.searchQuery.value = '';
                                  setState(() {});
                                },
                              ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final (filter, label) in [
                            (SurahFilter.all, 'All'),
                            (SurahFilter.juz, 'Juz'),
                            (SurahFilter.makki, 'Makkah'),
                            (SurahFilter.madani, 'Madinah'),
                            (SurahFilter.bookmarks, 'Saved'),
                          ])
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 8),
                              child: ChoiceChip(
                                label: Text(label),
                                selected: controller.filter.value == filter,
                                onSelected: (_) => controller.setFilter(filter),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (controller.filter.value == SurahFilter.juz)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: DropdownButtonFormField<int>(
                          initialValue: _juz,
                          decoration: const InputDecoration(labelText: 'Juz'),
                          items: [
                            for (var n = 1; n <= 30; n++)
                              DropdownMenuItem(value: n, child: Text('Juz $n')),
                          ],
                          onChanged: (value) =>
                              setState(() => _juz = value ?? 1),
                        ),
                      ),
                    if (controller.lastRead.value != null &&
                        _search.text.isEmpty) ...[
                      const SizedBox(height: 20),
                      PressableScale(
                        onTap: () {
                          final matches = controller.suwar.where(
                            (s) => s.id == controller.lastRead.value!.surahId,
                          );
                          if (matches.isNotEmpty) {
                            Get.toNamed(
                              AppRoutes.ayahReader,
                              arguments: matches.first,
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: colors.primary,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.bookOpen,
                                color: colors.onPrimary,
                                size: 30,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'CONTINUE READING',
                                      style: TextStyle(
                                        fontSize: 10,
                                        letterSpacing: 1.5,
                                        color: colors.onPrimary.withValues(
                                          alpha: .7,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      controller.lastRead.value!.surahName,
                                      style: TextStyle(
                                        color: colors.onPrimary,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Text(
                                      'Verse ${controller.lastRead.value!.ayah}',
                                      style: TextStyle(
                                        color: colors.onPrimary.withValues(
                                          alpha: .8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                LucideIcons.arrowRight,
                                color: colors.onPrimary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (controller.isLoading.value)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (controller.error.value.isNotEmpty)
              SliverFillRemaining(
                child: ErrorStateView(
                  message: controller.error.value,
                  onRetry: controller.fetchSuwar,
                ),
              )
            else if (surahs.isEmpty)
              const SliverFillRemaining(
                child: EmptyState(
                  title: 'No surahs found',
                  message: 'Try another search or filter.',
                  icon: LucideIcons.search,
                ),
              )
            else
              SliverList.builder(
                itemCount: surahs.length,
                itemBuilder: (context, index) =>
                    _SurahTile(surah: surahs[index]),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 150)),
          ],
        );
      }),
    );
  }
}

class _SurahTile extends StatelessWidget {
  const _SurahTile({required this.surah});
  final Surah surah;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Get.toNamed(AppRoutes.ayahReader, arguments: surah),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 4),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: colors.outlineVariant.withValues(alpha: .35),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${surah.id}',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quran.getSurahName(surah.id),
                        style: TextStyle(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${surah.revelationLabel} · ${quran.getVerseCount(surah.id)} verses',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    quran.getSurahNameArabic(surah.id),
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      fontFamily: 'Amiri',
                      color: colors.primary,
                      fontSize: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
