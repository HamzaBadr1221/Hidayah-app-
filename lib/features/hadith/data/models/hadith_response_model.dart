import '../../domain/entities/hadith_page.dart';
import 'hadith_model.dart';

class HadithResponseModel extends HadithPage {
  const HadithResponseModel({
    required super.name,
    required super.slug,
    required super.total,
    required super.currentPage,
    required super.totalPages,
    required super.items,
  });

  factory HadithResponseModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final pagination =
        json['pagination'] as Map<String, dynamic>? ?? {};

    final items = json['items'] as List<dynamic>? ?? [];

    return HadithResponseModel(
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      total: (json['total'] as num?)?.toInt() ?? 0,
      currentPage:
      (pagination['currentPage'] as num?)?.toInt() ?? 1,
      totalPages:
      (pagination['totalPages'] as num?)?.toInt() ?? 1,
      items: items
          .map(
            (item) => HadithModel.fromJson(
          item as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }
}