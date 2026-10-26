import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../app/routes/app_routes.dart';
import '../../data/worship_repository.dart';
import 'worship_library.dart';
import '../../../home/presentation/widgets/worship_art.dart';

class AzkarPage extends StatelessWidget {
  const AzkarPage({super.key});
  @override
  Widget build(BuildContext context) => WorshipLibrary<AzkarCategory>(
    title: 'Azkar',
    appBar: AppBar(
      title: const Text(
        'Azkar',
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
      ),
      centerTitle: true,
      toolbarHeight: 64,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: const RoundedRectangleBorder(),
    ),
    subtitle: '',
    load: WorshipRepository().categories,
    searchHint: 'Search azkar',
    searchText: (category) =>
        '${category.displayTitle} ${category.title} ${category.englishTitle ?? ''} ${category.transliteration ?? ''}',
    header: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF194D48),
            borderRadius: BorderRadius.circular(26),
          ),
          child: const Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'A moment of remembrance',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              WorshipArt(azkar: true, size: 82),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (final item in [
              ('Duas', AppRoutes.duas),
              ('99 Names', AppRoutes.allahNames),
              ('Tasbih', AppRoutes.tasbih),
            ])
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: ActionChip(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 8,
                    ),
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    label: Text(
                      item.$1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () => Get.toNamed(item.$2),
                  ),
                ),
              ),
          ],
        ),
      ],
    ),
    itemBuilder: (context, category) => Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: Icon(
          category.id == 1
              ? LucideIcons.sun
              : category.id == 2
              ? LucideIcons.moon
              : LucideIcons.bookOpen,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          category.displayTitle,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 6),
            Text(
              category.title,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontFamily: 'Amiri', fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              '${category.entries.length} adhkar',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        trailing: const Icon(LucideIcons.chevronRight),
        onTap: () => Get.toNamed(AppRoutes.azkarCategory, arguments: category),
      ),
    ),
  );
}
