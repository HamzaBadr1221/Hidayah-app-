import '../../domain/entities/hadith_book.dart';

class HadithBookModel extends HadithBook {
  const HadithBookModel({
    required super.name,
    required super.slug,
    required super.total,
  });

  factory HadithBookModel.fromJson(Map<String, dynamic> json) {
    return HadithBookModel(
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      total: (json['total'] as num?)?.toInt() ?? 0,
    );
  }
}