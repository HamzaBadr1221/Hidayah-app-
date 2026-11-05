import '../entities/hadith.dart';

class SearchHadiths {
  List<Hadith> call({
    required List<Hadith> hadiths,
    required String query,
  }) {
    final searchQuery = query.trim();

    if (searchQuery.isEmpty) {
      return hadiths;
    }

    return hadiths.where((hadith) {
      return hadith.arab.contains(searchQuery) ||
          (hadith.translation?.toLowerCase().contains(
            searchQuery.toLowerCase(),
          ) ??
              false);
    }).toList();
  }
}