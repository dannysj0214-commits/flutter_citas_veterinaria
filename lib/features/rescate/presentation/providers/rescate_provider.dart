import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/categorias_rescate_api.dart';
import '../../data/reportes_rescate_api.dart';
import '../../domain/categoria_rescate_model.dart';
import '../../domain/reporte_rescate_model.dart';

// ==================== APIs ====================
final categoriasRescateApiProvider = Provider<CategoriasRescateApi>((ref) {
  return CategoriasRescateApi();
});

final reportesRescateApiProvider = Provider<ReportesRescateApi>((ref) {
  return ReportesRescateApi();
});

// ==================== CATEGORÍAS ====================
final categoriasRescateProvider =
    FutureProvider<List<CategoriaRescate>>((ref) async {
  final api = ref.watch(categoriasRescateApiProvider);
  final raw = await api.listar();
  return raw
      .map((e) => CategoriaRescate.fromJson(e as Map<String, dynamic>))
      .toList();
});

// ==================== REPORTES ====================
final reportesRescateProvider =
    FutureProvider<List<ReporteRescate>>((ref) async {
  final api = ref.watch(reportesRescateApiProvider);
  final raw = await api.listar();
  return raw
      .map((e) => ReporteRescate.fromJson(e as Map<String, dynamic>))
      .toList();
});

// ==================== DETALLE ====================
final reporteDetalleProvider =
    FutureProvider.family<ReporteRescate, String>((ref, id) async {
  final api = ref.watch(reportesRescateApiProvider);
  final raw = await api.obtener(id);
  return ReporteRescate.fromJson(raw);
});