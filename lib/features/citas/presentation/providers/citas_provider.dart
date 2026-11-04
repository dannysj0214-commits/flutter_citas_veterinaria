import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/citas_api.dart';
import '../../domain/cita_model.dart';

final citasApiProvider = Provider((ref) => CitasApi());

final citasClienteProvider =
    FutureProvider.autoDispose<List<CitaModel>>((ref) async {
  final api = ref.read(citasApiProvider);
  final data = await api.citasCliente();
  return data.map((e) => CitaModel.fromJson(e)).toList();
});

final citasProfesionalProvider =
    FutureProvider.autoDispose<List<CitaModel>>((ref) async {
  final api = ref.read(citasApiProvider);
  final data = await api.citasProfesional();
  return data.map((e) => CitaModel.fromJson(e)).toList();
});

final profesionalesProvider =
    FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.read(citasApiProvider);
  return await api.profesionales();
});