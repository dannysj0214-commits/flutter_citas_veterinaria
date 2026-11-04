import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class HistoriasApi {
  final Dio _dio = DioClient().dio;

  Future<List<dynamic>> historiasCliente() async {
    final response = await _dio.get('/medical-records/cliente');
    return response.data['data'] ?? [];
  }

  Future<List<dynamic>> historiasProfesional() async {
    final response = await _dio.get('/medical-records/profesional/todas');
    return response.data['data'] ?? [];
  }

  // 🌟 NUEVO MÉTODO: Obtener la lista de clientes
  Future<List<dynamic>> obtenerClientes() async {
    final response = await _dio.get('/admin/clientes');
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> crear(Map<String, dynamic> data) async {
    final response = await _dio.post('/medical-records', data: data);
    return response.data;
  }
}