import 'hadith.dart';

class HadithPage {
  final String name;
  final String slug;
  final int total;
  final int currentPage;
  final int totalPages;
  final List<Hadith> items;

  const HadithPage({
    required this.name,
    required this.slug,
    required this.total,
    required this.currentPage,
    required this.totalPages,
    required this.items,
  });
}