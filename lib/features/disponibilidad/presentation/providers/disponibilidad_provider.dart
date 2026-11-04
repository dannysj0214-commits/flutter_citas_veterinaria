import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/disponibilidad_api.dart';
import '../../domain/disponibilidad_model.dart';

final disponibilidadApiProvider = Provider((ref) => DisponibilidadApi());

final misHorariosProvider =
    FutureProvider.autoDispose<List<Disponibilidad>>((ref) async {
  final api = ref.read(disponibilidadApiProvider);
  final data = await api.misHorarios();
  return data.map((e) => Disponibilidad.fromJson(e)).toList();
});