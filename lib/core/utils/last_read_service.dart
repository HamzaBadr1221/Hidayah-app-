import 'package:shared_preferences/shared_preferences.dart';

class LastReadService {
  static const String _surahKey = 'last_read_surah';
  static const String _pageKey = 'last_read_page';

  static Future<void> save({
    required int surahNumber,
    required int pageNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(_surahKey, surahNumber);
    await prefs.setInt(_pageKey, pageNumber);
  }

  static Future<Map<String, int>?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();

    final surahNumber = prefs.getInt(_surahKey);
    final pageNumber = prefs.getInt(_pageKey);

    if (surahNumber == null || pageNumber == null) {
      return null;
    }

    return {
      'surahNumber': surahNumber,
      'pageNumber': pageNumber,
    };
  }
}