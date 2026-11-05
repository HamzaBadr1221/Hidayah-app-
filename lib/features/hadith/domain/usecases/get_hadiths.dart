import '../entities/hadith_page.dart';
import '../repositories/hadith_repository.dart';

class GetHadiths {
  final HadithRepository repository;

  GetHadiths(this.repository);

  Future<HadithPage> call({
    required String slug,
    required int page,
    required int limit,
  }) {
    return repository.getHadiths(
      slug: slug,
      page: page,
      limit: limit,
    );
  }
}