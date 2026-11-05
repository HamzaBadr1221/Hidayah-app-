import 'package:dio/dio.dart';
import '../models/hadith_book_model.dart';
import '../models/hadith_response_model.dart';

abstract class HadithRemoteDataSource {
  Future<List<HadithBookModel>> getBooks();

  Future<HadithResponseModel> getHadiths({
    required String slug,
    required int page,
    required int limit,
  });
}

class HadithRemoteDataSourceImpl implements HadithRemoteDataSource {
  final Dio dio;

  HadithRemoteDataSourceImpl(this.dio);

  @override
  Future<List<HadithBookModel>> getBooks() async {
    final response = await dio.get('/hadith');

    final data = response.data as List<dynamic>;

    return data
        .map(
          (item) => HadithBookModel.fromJson(
        item as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  @override
  Future<HadithResponseModel> getHadiths({
    required String slug,
    required int page,
    required int limit,
  }) async {
    final response = await dio.get(
      '/hadith/$slug',
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );

    return HadithResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}