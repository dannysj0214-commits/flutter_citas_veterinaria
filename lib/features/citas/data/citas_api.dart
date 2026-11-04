import 'package:dio/dio.dart';
import '../../../core/config/api_config.dart';
import '../../../core/network/dio_client.dart';

class CitasApi {
  final Dio _dio = DioClient().dio;

  Future<List<dynamic>> citasCliente() async {
    final response = await _dio.get(ApiConfig.appointmentsCliente);
    return response.data['data'] ?? [];
  }

  Future<List<dynamic>> citasProfesional() async {
    final response = await _dio.get(ApiConfig.appointmentsProfesional);
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> crear(Map<String, dynamic> data) async {
    final response = await _dio.post(ApiConfig.appointments, data: data);
    return response.data;
  }

  Future<Map<String, dynamic>> cambiarEstado(String id, String estado) async {
    final response = await _dio.put(
      '${ApiConfig.appointments}/$id/estado',
      data: {'estado': estado},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> cancelar(String id) async {
    final response = await _dio.delete('${ApiConfig.appointments}/$id');
    return response.data;
  }

  Future<List<String>> disponibles(String profesionalId, String fecha) async {
    final response = await _dio.get(
      '${ApiConfig.appointments}/disponibles/$profesionalId',
      queryParameters: {'fecha': fecha},
    );
    final data = response.data['data'] as List? ?? [];
    return data.map((e) => e.toString()).toList();
  }

  Future<List<dynamic>> profesionales() async {
    final response = await _dio.get(ApiConfig.profesionales);
    return response.data['data'] ?? [];
  }
}