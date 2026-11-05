import '../entities/hadith_book.dart';
import '../entities/hadith_page.dart';

abstract class HadithRepository {
  Future<List<HadithBook>> getBooks();

  Future<HadithPage> getHadiths({
    required String slug,
    required int page,
    required int limit,
  });
}