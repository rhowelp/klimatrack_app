import 'package:dio/dio.dart';
import 'package:klimatrack_app/domain/constants/constants.dart';

class DioClient {
  static Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Constants.baseUrl,
        queryParameters: {
          'appid': Constants.apiKey,
        },
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      requestHeader: true,
      responseBody: true,
    ));

    return dio;
  }
}
