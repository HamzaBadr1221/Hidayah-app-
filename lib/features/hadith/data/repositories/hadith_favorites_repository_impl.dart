import '../../domain/entities/favorite_hadith.dart';
import '../../domain/repositories/hadith_favorites_repository.dart';
import '../datasources/hadith_local_data_source.dart';

class HadithFavoritesRepositoryImpl
    implements HadithFavoritesRepository {
  final HadithLocalDataSource localDataSource;

  HadithFavoritesRepositoryImpl(this.localDataSource);

  @override
  Future<List<FavoriteHadith>> getFavorites() {
    return localDataSource.getFavorites();
  }

  @override
  Future<void> saveFavorites(List<FavoriteHadith> favorites) {
    return localDataSource.saveFavorites(favorites);
  }
}