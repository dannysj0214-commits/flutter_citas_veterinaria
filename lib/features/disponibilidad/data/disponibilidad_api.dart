import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';

class DisponibilidadApi {
  final Dio _dio = DioClient().dio;

  Future<List<dynamic>> misHorarios() async {
    final response = await _dio.get('/availability/mis-horarios');
    return response.data['data'] ?? [];
  }

  Future<Map<String, dynamic>> crear({
    required int diaSemana,
    required String horaInicio,
    required String horaFin,
  }) async {
    final response = await _dio.post('/availability', data: {
      'dia_semana': diaSemana,
      'hora_inicio': horaInicio,
      'hora_fin': horaFin,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> eliminar(String id) async {
    final response = await _dio.delete('/availability/$id');
    return response.data;
  }
}