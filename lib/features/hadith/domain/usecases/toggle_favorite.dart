import '../entities/favorite_hadith.dart';
import '../repositories/hadith_favorites_repository.dart';

class ToggleFavorite {
  final HadithFavoritesRepository repository;

  ToggleFavorite(this.repository);

  Future<List<FavoriteHadith>> call({
    required FavoriteHadith hadith,
    required List<FavoriteHadith> currentFavorites,
  }) async {
    final updatedFavorites = List<FavoriteHadith>.from(currentFavorites);

    final index = updatedFavorites.indexWhere(
          (item) =>
      item.bookSlug == hadith.bookSlug &&
          item.number == hadith.number,
    );

    if (index >= 0) {
      updatedFavorites.removeAt(index);
    } else {
      updatedFavorites.add(hadith);
    }

    await repository.saveFavorites(updatedFavorites);

    return updatedFavorites;
  }
}