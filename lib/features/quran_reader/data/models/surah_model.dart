import '../../domain/entities/surah.dart';

class SurahModel extends Surah {
  const SurahModel({
    required super.id,
    required super.name,
    required super.startPage,
    required super.endPage,
    required super.type,
    required super.juz,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) => SurahModel(
        id: json['id'] as int,
        name: (json['name'] as String).trim(),
        startPage: json['start_page'] as int,
        endPage: json['end_page'] as int,
        juz: (json['juz'] as int?) ?? 1,
        // makkia: 1 = Makki, 0 = Madani
        type: (json['makkia'] as int) == 1
            ? RevelationType.makkah
            : RevelationType.madina,
      );

  /// Serialized back into the API's wire shape so a cached copy round-trips
  /// through [SurahModel.fromJson] unchanged.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'start_page': startPage,
        'end_page': endPage,
        'juz': juz,
        'makkia': type == RevelationType.makkah ? 1 : 0,
      };
}
