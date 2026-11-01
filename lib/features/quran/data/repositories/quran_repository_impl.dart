import '../../domain/entities/surah.dart';
import '../../domain/repositories/quran_repository.dart';
import '../data_sources/quran_remote_data_source.dart';

class QuranRepositoryImpl implements QuranRepository {
  final QuranRemoteDataSource remoteDataSource;

  QuranRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Surah>> getSurahs() {
    return remoteDataSource.getSurahs();
  }

  @override
  Future<Surah> getSurahDetails(int number) {
    return remoteDataSource.getSurahDetails(number);
  }
}