import 'package:dio/dio.dart';

class DioFactory {
  DioFactory._();

  static Dio createDio() {
    return Dio(
      BaseOptions(
        baseUrl: 'https://api.alquran.cloud/v1',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );
  }
}