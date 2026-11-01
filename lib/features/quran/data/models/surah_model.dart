import '../../domain/entities/surah.dart';

class SurahModel extends Surah {
  const SurahModel({
    required super.number,
    required super.name,
    required super.englishName,
    required super.englishNameTranslation,
    required super.numberOfAyahs,
    required super.revelationType,
    super.ayahs,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    final rawAyahs = json['ayahs'] as List<dynamic>? ?? [];

    return SurahModel(
      number: (json['number'] as num).toInt(),
      name: json['name'] as String? ?? '',
      englishName: json['englishName'] as String? ?? '',
      englishNameTranslation:
      json['englishNameTranslation'] as String? ?? '',
      numberOfAyahs:
      (json['numberOfAyahs'] as num?)?.toInt() ?? 0,
      revelationType: json['revelationType'] as String? ?? '',
      ayahs: rawAyahs.map((item) {
        final ayah = item as Map<String, dynamic>;

        return Ayah(
          number: (ayah['number'] as num).toInt(),
          numberInSurah:
          (ayah['numberInSurah'] as num).toInt(),
          text: ayah['text'] as String? ?? '',
        );
      }).toList(),
    );
  }
}