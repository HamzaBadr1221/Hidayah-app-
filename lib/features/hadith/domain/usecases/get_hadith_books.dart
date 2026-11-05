import '../entities/hadith_book.dart';
import '../repositories/hadith_repository.dart';

class GetHadithBooks {
  final HadithRepository repository;

  GetHadithBooks(this.repository);

  Future<List<HadithBook>> call() {
    return repository.getBooks();
  }
}