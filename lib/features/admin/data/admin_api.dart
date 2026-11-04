import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class AdminApi {
  final Dio _dio = DioClient().dio;

  Future<List<dynamic>> listarUsuarios() async {
    final response = await _dio.get('/admin/usuarios');
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> crearUsuario(Map<String, dynamic> data) async {
    final response = await _dio.post('/admin/usuarios', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> eliminarUsuario(String id) async {
    final response = await _dio.delete('/admin/usuarios/$id');
    return response.data;
  }
}