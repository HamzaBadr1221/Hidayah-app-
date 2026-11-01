import 'package:dio/dio.dart';

class SurahPageApi {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.alquran.cloud/v1',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ),
  );

  Future<int> getFirstPage(int surahNumber) async {
    final response = await _dio.get(
      '/surah/$surahNumber/quran-uthmani',
    );

    final data = response.data['data'];
    final ayahs = data['ayahs'] as List;

    if (ayahs.isEmpty) {
      throw Exception('لم يتم العثور على آيات للسورة');
    }

    return ayahs.first['page'] as int;
  }

  Future<Map<String, dynamic>> getPage(int pageNumber) async {
    if (pageNumber < 1 || pageNumber > 604) {
      throw Exception('رقم الصفحة خارج النطاق');
    }

    final response = await _dio.get(
      '/page/$pageNumber/quran-uthmani',
    );

    return Map<String, dynamic>.from(response.data['data']);
  }

  Future<int> getSurahNumberFromPage(int pageNumber) async {
    final pageData = await getPage(pageNumber);
    final ayahs = pageData['ayahs'] as List;

    if (ayahs.isEmpty) {
      throw Exception('لم يتم العثور على آيات الصفحة');
    }

    return ayahs.first['surah']['number'] as int;
  }
}