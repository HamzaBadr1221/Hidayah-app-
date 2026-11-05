import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/favorite_hadith.dart';

abstract class HadithLocalDataSource {
  Future<List<FavoriteHadith>> getFavorites();

  Future<void> saveFavorites(List<FavoriteHadith> favorites);
}

class HadithLocalDataSourceImpl implements HadithLocalDataSource {
  final SharedPreferences sharedPreferences;

  HadithLocalDataSourceImpl(this.sharedPreferences);

  static const String favoritesKey = 'hadith_favorites';

  @override
  Future<List<FavoriteHadith>> getFavorites() async {
    final savedData = sharedPreferences.getString(favoritesKey);

    if (savedData == null) return [];

    final decodedData = jsonDecode(savedData) as List<dynamic>;

    return decodedData
        .map(
          (item) => FavoriteHadith.fromJson(
        item as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  @override
  Future<void> saveFavorites(List<FavoriteHadith> favorites) async {
    final encodedData = jsonEncode(
      favorites.map((item) => item.toJson()).toList(),
    );

    await sharedPreferences.setString(favoritesKey, encodedData);
  }
}