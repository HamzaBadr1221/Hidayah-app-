import '../entities/favorite_hadith.dart';
import '../repositories/hadith_favorites_repository.dart';

class GetFavorites {
  final HadithFavoritesRepository repository;

  GetFavorites(this.repository);

  Future<List<FavoriteHadith>> call() {
    return repository.getFavorites();
  }
}