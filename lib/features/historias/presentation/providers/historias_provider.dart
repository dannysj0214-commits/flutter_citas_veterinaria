import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/historias_api.dart';
import '../../domain/historia_model.dart';

final historiasApiProvider = Provider((ref) => HistoriasApi());

final historiasClienteProvider =
    FutureProvider.autoDispose<List<HistoriaModel>>((ref) async {
  final api = ref.read(historiasApiProvider);
  final data = await api.historiasCliente();
  return data.map((e) => HistoriaModel.fromJson(e)).toList();
});

final historiasProfesionalProvider =
    FutureProvider.autoDispose<List<HistoriaModel>>((ref) async {
  final api = ref.read(historiasApiProvider);
  final data = await api.historiasProfesional();
  return data.map((e) => HistoriaModel.fromJson(e)).toList();
});

// 🌟 NUEVO PROVIDER: Para obtener la lista de clientes en el Dropdown
final clientesProvider = FutureProvider.autoDispose<List<dynamic>>((ref) async {
  final api = ref.read(historiasApiProvider);
  return await api.obtenerClientes();
});