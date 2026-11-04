import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../domain/estadisticas_model.dart';

class EstadisticasApi {
  final Dio _dio = DioClient().dio;

  Future<EstadisticasModel> getEstadisticas() async {
    final response = await _dio.get('/reports/stats');
    return EstadisticasModel.fromJson(response.data['data']);
  }
}