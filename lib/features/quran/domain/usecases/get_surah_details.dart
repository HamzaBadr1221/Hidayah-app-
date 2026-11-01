import '../entities/surah.dart';
import '../repositories/quran_repository.dart';

class GetSurahDetails {
  final QuranRepository repository;

  GetSurahDetails(this.repository);

  Future<Surah> call(int number) {
    return repository.getSurahDetails(number);
  }
}