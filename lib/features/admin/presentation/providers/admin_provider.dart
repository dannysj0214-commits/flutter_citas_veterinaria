import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/admin_api.dart';
import '../../domain/usuario_model.dart';

final adminApiProvider = Provider<AdminApi>((ref) => AdminApi());

final usuariosProvider = FutureProvider<List<Usuario>>((ref) async {
  return ref.watch(adminApiProvider).listarUsuarios();
});