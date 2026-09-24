import 'package:dio/dio.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/dio_client.dart';

class AuthApi {
  final Dio _dio = DioClient().dio;

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post(ApiConfig.login, data: {
      'email': email,
      'password': password,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConfig.register, data: data);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _dio.get(ApiConfig.profile);
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getProfesionales() async {
    final response = await _dio.get(ApiConfig.profesionales);
    return response.data as Map<String, dynamic>;
  }
}