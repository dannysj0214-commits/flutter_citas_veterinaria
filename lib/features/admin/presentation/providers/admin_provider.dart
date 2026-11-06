import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/admin_api.dart';
import '../../domain/usuario_model.dart';

final adminApiProvider = Provider((ref) => AdminApi());

final usuariosProvider = FutureProvider.autoDispose<List<UsuarioModel>>((ref) async {
  final api = ref.read(adminApiProvider);
  final data = await api.listarUsuarios();
  return data.map((e) => UsuarioModel.fromJson(e)).toList();
});