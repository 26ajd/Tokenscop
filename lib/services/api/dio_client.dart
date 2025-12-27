import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../helpera/constants.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio _dio;
  factory DioClient() {
    return _instance;
  }
  DioClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: AppConstants.apiConnectTimeout),
        receiveTimeout: const Duration(seconds: AppConstants.apiReceiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': '*/*'
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final settingsBox = Hive.box(AppConstants.boxSettings);
          final token = settingsBox.get(AppConstants.keyToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }
}
