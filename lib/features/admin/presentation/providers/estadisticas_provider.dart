import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/estadisticas_api.dart';
import '../../domain/estadisticas_model.dart';

final estadisticasApiProvider = Provider((ref) => EstadisticasApi());

final estadisticasProvider = FutureProvider.autoDispose<EstadisticasModel>((ref) async {
  final api = ref.read(estadisticasApiProvider);
  return await api.getEstadisticas();
});