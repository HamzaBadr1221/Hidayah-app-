import '../entities/favorite_hadith.dart';

abstract class HadithFavoritesRepository {
  Future<List<FavoriteHadith>> getFavorites();

  Future<void> saveFavorites(List<FavoriteHadith> favorites);
}