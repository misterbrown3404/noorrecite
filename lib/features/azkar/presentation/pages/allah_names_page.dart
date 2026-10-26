import 'package:flutter/material.dart';
import '../../data/worship_repository.dart';
import 'worship_library.dart';

class AllahNamesPage extends StatelessWidget {
  const AllahNamesPage({super.key, this.repository});
  final WorshipRepository? repository;
  @override
  Widget build(BuildContext context) => WorshipLibrary<AllahName>(
    title: '99 Names of Allah',
    subtitle: 'Asma ul Husna',
    load: (repository ?? WorshipRepository()).names,
    searchText: (name) => name.searchText,
    searchHint: 'Search a name, number, or meaning',
    header: Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF194D48), Color(0xFF102F30)],
        ),
        borderRadius: BorderRadius.circular(28),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'أَسْمَاءُ اللَّهِ الْحُسْنَى',
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 32,
              color: Color(0xFFE7D8AB),
              height: 1.8,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Read. Reflect. Remember.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, letterSpacing: 1),
          ),
        ],
      ),
    ),
    itemBuilder: (context, name) => WorshipTextCard(
      title: name.number.toString().padLeft(2, '0'),
      arabic: name.arabic,
      transliteration: name.transliteration,
      meaning: name.meaning,
    ),
  );
}
