import 'package:equatable/equatable.dart';

class Moshaf extends Equatable {
  const Moshaf({
    required this.id,
    required this.name,
    required this.server,
    required this.surahTotal,
    required this.surahList,
  });

  final int id;
  final String name;
  final String server;
  final int surahTotal;
  final List<int> surahList;

  String audioUrl(int surahNumber) {
    final base = server.endsWith('/') ? server : '$server/';
    return '$base${surahNumber.toString().padLeft(3, '0')}.mp3';
  }

  bool hasSurah(int surahNumber) => surahList.contains(surahNumber);

  @override
  List<Object> get props => [id];
}

class Reciter extends Equatable {
  const Reciter({
    required this.id,
    required this.name,
    required this.letter,
    required this.moshaf,
  });

  final int id;
  final String name;
  final String letter;
  final List<Moshaf> moshaf;

  Moshaf? get primaryMoshaf => moshaf.isNotEmpty ? moshaf.first : null;

  @override
  List<Object> get props => [id];
}
