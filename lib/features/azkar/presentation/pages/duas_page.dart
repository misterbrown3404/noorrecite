import 'package:flutter/material.dart';
import '../../data/worship_repository.dart';
import 'worship_library.dart';

class DuasPage extends StatelessWidget {
  const DuasPage({super.key});
  @override
  Widget build(BuildContext context) => WorshipLibrary<Dua>(
    title: 'Dua collection',
    subtitle: 'Words of hope, gratitude, and reliance.',
    load: WorshipRepository().duas,
    searchText: (dua) => dua.searchText,
    searchHint: 'Search a topic or phrase',
    itemBuilder: (context, dua) => WorshipTextCard(
      title: dua.title,
      arabic: dua.arabic,
      transliteration: dua.transliteration,
      meaning: dua.translation,
      reference: dua.reference,
    ),
  );
}
