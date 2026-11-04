import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class NotificacionesApi {
  final Dio _dio = DioClient().dio;

  Future<List<dynamic>> listar() async {
    final response = await _dio.get('/notifications');
    return response.data['data'] ?? [];
  }
}