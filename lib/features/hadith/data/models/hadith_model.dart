import '../../domain/entities/hadith.dart';

class HadithModel extends Hadith {
  const HadithModel({
    required super.number,
    required super.arab,
    super.translation,
  });

  factory HadithModel.fromJson(Map<String, dynamic> json) {
    return HadithModel(
      number: (json['number'] as num?)?.toInt() ?? 0,
      arab: json['arab']?.toString() ?? '',
      translation: json['id']?.toString(),
    );
  }
}