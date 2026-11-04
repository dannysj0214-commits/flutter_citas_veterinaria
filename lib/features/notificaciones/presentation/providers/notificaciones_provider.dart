import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/notificaciones_api.dart';
import '../../domain/notificacion_model.dart';

final notificacionesApiProvider = Provider((ref) => NotificacionesApi());

final notificacionesProvider = FutureProvider.autoDispose<List<NotificacionModel>>((ref) async {
  final api = ref.read(notificacionesApiProvider);
  final data = await api.listar();
  return data.map((e) => NotificacionModel.fromJson(e)).toList();
});