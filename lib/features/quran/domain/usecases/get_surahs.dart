import '../entities/surah.dart';
import '../repositories/quran_repository.dart';

class GetSurahs {
  final QuranRepository repository;

  GetSurahs(this.repository);

  Future<List<Surah>> call() {
    return repository.getSurahs();
  }
}