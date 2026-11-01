import 'package:dio/dio.dart';

abstract class PrayerRemoteDataSource {
  Future<Map<String, dynamic>> getPrayerTimes({
    required String city,
    required String country,
    required String date,
  });
}

class PrayerRemoteDataSourceImpl implements PrayerRemoteDataSource {
  final Dio dio;

  PrayerRemoteDataSourceImpl(this.dio);

  @override
  Future<Map<String, dynamic>> getPrayerTimes({
    required String city,
    required String country,
    required String date,
  }) async {
    final response = await dio.get(
      'https://api.aladhan.com/v1/timingsByCity/$date',
      queryParameters: {
        'city': city,
        'country': country,
        'method': 5,
      },
    );

    final body = response.data as Map<String, dynamic>;

    if (body['code'] != 200) {
      throw Exception('Failed to fetch prayer times');
    }

    return body['data'] as Map<String, dynamic>;
  }
}