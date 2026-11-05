import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/favorite_hadith.dart';
import '../../domain/usecases/get_favorites.dart';
import '../../domain/usecases/toggle_favorite.dart';

enum HadithFavoritesStatus {
  initial,
  loading,
  updating,
  success,
  failure,
}

class HadithFavoritesCubit extends Cubit<HadithFavoritesStatus> {
  final GetFavorites getFavorites;
  final ToggleFavorite toggleFavorite;

  HadithFavoritesCubit({
    required this.getFavorites,
    required this.toggleFavorite,
  }) : super(HadithFavoritesStatus.initial);

  List<FavoriteHadith> favorites = [];

  bool _isUpdating = false;

  Future<void> fetchFavorites() async {
    emit(HadithFavoritesStatus.loading);

    try {
      favorites = await getFavorites();
      emit(HadithFavoritesStatus.success);
    } catch (error) {
      emit(HadithFavoritesStatus.failure);
    }
  }

  bool isFavorite({
    required String bookSlug,
    required int number,
  }) {
    return favorites.any(
          (item) =>
      item.bookSlug == bookSlug &&
          item.number == number,
    );
  }

  Future<void> toggle({
    required FavoriteHadith hadith,
  }) async {
    if (_isUpdating) return;

    _isUpdating = true;

    final previousFavorites =
    List<FavoriteHadith>.from(favorites);

    final alreadyFavorite = isFavorite(
      bookSlug: hadith.bookSlug,
      number: hadith.number,
    );

    if (alreadyFavorite) {
      favorites = List<FavoriteHadith>.from(previousFavorites)
        ..removeWhere(
              (item) =>
          item.bookSlug == hadith.bookSlug &&
              item.number == hadith.number,
        );
    } else {
      favorites = List<FavoriteHadith>.from(previousFavorites)
        ..add(hadith);
    }

    emit(HadithFavoritesStatus.updating);

    try {
      favorites = await toggleFavorite(
        hadith: hadith,
        currentFavorites: previousFavorites,
      );

      emit(HadithFavoritesStatus.success);
    } catch (error) {
      favorites = previousFavorites;

      emit(HadithFavoritesStatus.failure);
    } finally {
      _isUpdating = false;
    }
  }
}