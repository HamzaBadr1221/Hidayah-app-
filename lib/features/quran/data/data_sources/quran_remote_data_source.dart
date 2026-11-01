import 'package:dio/dio.dart';
import '../models/surah_model.dart';

abstract class QuranRemoteDataSource {
  Future<List<SurahModel>> getSurahs();

  Future<SurahModel> getSurahDetails(int number);
}

class QuranRemoteDataSourceImpl implements QuranRemoteDataSource {
  final Dio dio;

  QuranRemoteDataSourceImpl(this.dio);

  @override
  Future<List<SurahModel>> getSurahs() async {
    final response = await dio.get('/surah');

    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as List<dynamic>;

    return data.map((item) {
      return SurahModel.fromJson(
        item as Map<String, dynamic>,
      );
    }).toList();
  }

  @override
  Future<SurahModel> getSurahDetails(int number) async {
    final response = await dio.get('/surah/$number');

    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;

    return SurahModel.fromJson(data);
  }
}