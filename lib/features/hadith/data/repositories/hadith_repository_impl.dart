import '../../domain/entities/hadith_book.dart';
import '../../domain/entities/hadith_page.dart';
import '../../domain/repositories/hadith_repository.dart';
import '../datasources/hadith_remote_data_source.dart';

class HadithRepositoryImpl implements HadithRepository {
  final HadithRemoteDataSource remoteDataSource;

  HadithRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<HadithBook>> getBooks() {
    return remoteDataSource.getBooks();
  }

  @override
  Future<HadithPage> getHadiths({
    required String slug,
    required int page,
    required int limit,
  }) {
    return remoteDataSource.getHadiths(
      slug: slug,
      page: page,
      limit: limit,
    );
  }
}