import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage_service.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  late final Dio dio = _createDio();

  Dio _createDio() {
    final dio = Dio(BaseOptions(
      // 👇 IP FORZADA DIRECTAMENTE PARA EL CELULAR Y EMULADOR
      baseUrl: 'http://192.168.101.16:5000/api',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorageService.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        if (kDebugMode) {
          debugPrint('→ ${options.method} ${options.uri}');
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (kDebugMode) {
          debugPrint('✗ ${error.response?.statusCode} ${error.requestOptions.uri}');
        }
        if (error.response?.statusCode == 401) {
          await SecureStorageService.clearAll();
        }
        handler.next(error);
      },
    ));

    return dio;
  }
}