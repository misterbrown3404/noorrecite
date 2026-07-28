import '../../domain/entities/reciter.dart';

class MoshafModel extends Moshaf {
  const MoshafModel({
    required super.id,
    required super.name,
    required super.server,
    required super.surahTotal,
    required super.surahList,
  });

  factory MoshafModel.fromJson(Map<String, dynamic> json) => MoshafModel(
        id: json['id'] as int,
        name: json['name'] as String,
        server: json['server'] as String,
        surahTotal: json['surah_total'] as int,
        surahList: (json['surah_list'] as String)
            .split(',')
            .map(int.parse)
            .toList(),
      );

  /// Serialized back into the API's wire shape so a cached copy round-trips
  /// through [MoshafModel.fromJson] unchanged.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'server': server,
        'surah_total': surahTotal,
        'surah_list': surahList.join(','),
      };
}

class ReciterModel extends Reciter {
  const ReciterModel({
    required super.id,
    required super.name,
    required super.letter,
    required super.moshaf,
  });

  factory ReciterModel.fromJson(Map<String, dynamic> json) => ReciterModel(
        id: json['id'] as int,
        name: json['name'] as String,
        letter: json['letter'] as String,
        moshaf: (json['moshaf'] as List)
            .map<Moshaf>((m) => MoshafModel.fromJson(m as Map<String, dynamic>))
            .toList(),
      );

  /// Serialized back into the API's wire shape for caching. Each [Moshaf] is
  /// re-wrapped in a [MoshafModel] so nested entities serialize too.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'letter': letter,
        'moshaf': moshaf
            .map(
              (m) => MoshafModel(
                id: m.id,
                name: m.name,
                server: m.server,
                surahTotal: m.surahTotal,
                surahList: m.surahList,
              ).toJson(),
            )
            .toList(),
      };
}
