import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class CategoriasRescateApi {
  final Dio _dio = DioClient().dio;

  Future<List<dynamic>> listar() async {
    final response = await _dio.get('/categorias-rescate');
    return response.data['data'] ?? [];
  }

  Future<List<dynamic>> listarTodas() async {
    final response = await _dio.get('/categorias-rescate/todas');
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> crear(Map<String, dynamic> data) async {
    final response = await _dio.post('/categorias-rescate', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> actualizar(String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/categorias-rescate/$id', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> eliminar(String id) async {
    final response = await _dio.delete('/categorias-rescate/$id');
    return response.data;
  }
}