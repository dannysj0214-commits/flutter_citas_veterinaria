import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class ReportesRescateApi {
  final Dio _dio = DioClient().dio;

  Future<List<dynamic>> listar({
    String? categoria,
    String? estado,
    String? especie,
    String? busqueda,
  }) async {
    final query = <String, dynamic>{};
    if (categoria != null && categoria.isNotEmpty) {
      query['categoria'] = categoria;
    }
    if (estado != null && estado.isNotEmpty) query['estado'] = estado;
    if (especie != null && especie.isNotEmpty) query['especie'] = especie;
    if (busqueda != null && busqueda.isNotEmpty) query['busqueda'] = busqueda;

    final response = await _dio.get(
      '/reportes-rescate',
      queryParameters: query,
    );
    return response.data['data'] ?? [];
  }

  Future<List<dynamic>> misReportes() async {
    final response = await _dio.get('/reportes-rescate/mis-reportes');
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> estadisticas() async {
    final response = await _dio.get('/reportes-rescate/estadisticas');
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> obtener(String id) async {
    final response = await _dio.get('/reportes-rescate/$id');
    return response.data['data'] ?? {};
  }

  Future<Map<String, dynamic>> crear(Map<String, dynamic> data) async {
    final response = await _dio.post('/reportes-rescate', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> actualizar(
      String id, Map<String, dynamic> data) async {
    final response = await _dio.put('/reportes-rescate/$id', data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> agregarSeguimiento(
      String id, String mensaje) async {
    final response = await _dio.post(
      '/reportes-rescate/$id/seguimiento',
      data: {'mensaje': mensaje},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> eliminar(String id) async {
    final response = await _dio.delete('/reportes-rescate/$id');
    return response.data;
  }
}