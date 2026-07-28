import 'package:equatable/equatable.dart';

enum RevelationType { makkah, madina }

class Surah extends Equatable {
  const Surah({
    required this.id,
    required this.name,
    required this.startPage,
    required this.endPage,
    required this.type,
    required this.juz,
  });

  final int id;
  final String name;
  final int startPage;
  final int endPage;
  final RevelationType type;
  final int juz;

  String get revelationLabel =>
      type == RevelationType.makkah ? 'Makkah' : 'Madina';

  @override
  List<Object> get props => [id];
}
