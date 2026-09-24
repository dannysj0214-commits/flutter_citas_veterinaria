import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../domain/usuario_model.dart';

class AdminApi {
  final Dio _dio = DioClient().dio;

  Future<List<Usuario>> listarUsuarios() async {
    final response = await _dio.get('/admin/usuarios');
    final raw = response.data['data'] as List? ?? [];
    return raw
        .map((e) => Usuario.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> crearUsuario({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    required String rol,
    String? especialidad,
  }) async {
    final response = await _dio.post('/admin/usuarios', data: {
      'nombre': nombre,
      'email': email,
      'password': password,
      'telefono': telefono,
      'rol': rol,
      if (especialidad != null && especialidad.isNotEmpty)
        'especialidad': especialidad,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> actualizarUsuario(
    String id, {
    String? nombre,
    String? email,
    String? telefono,
    String? rol,
    String? especialidad,
  }) async {
    final response = await _dio.put('/admin/usuarios/$id', data: {
      if (nombre != null) 'nombre': nombre,
      if (email != null) 'email': email,
      if (telefono != null) 'telefono': telefono,
      if (rol != null) 'rol': rol,
      if (especialidad != null && especialidad.isNotEmpty)
        'especialidad': especialidad,
    });
    return response.data;
  }

  Future<Map<String, dynamic>> eliminarUsuario(String id) async {
    final response = await _dio.delete('/admin/usuarios/$id');
    return response.data;
  }
}