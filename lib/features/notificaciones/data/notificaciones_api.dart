import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class NotificacionesApi {
  final Dio _dio = DioClient().dio;

  Future<List<dynamic>> listar() async {
    final response = await _dio.get('/notifications');
    return response.data['data'] ?? [];
  }

  // 🌟 Marcar UNA notificación como leída
  Future<void> marcarLeida(String id) async {
    await _dio.put('/notifications/$id/leer');
  }

  // 🌟 Marcar TODAS como leídas
  Future<void> marcarTodasLeidas() async {
    await _dio.put('/notifications/leer-todas');
  }
}