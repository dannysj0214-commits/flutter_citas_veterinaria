import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/categorias_rescate_api.dart';
import '../../data/reportes_rescate_api.dart';
import '../../domain/categoria_rescate_model.dart';
import '../../domain/reporte_rescate_model.dart';

// ============================================================
// CATEGORÍAS
// ============================================================

final categoriasRescateApiProvider = Provider((ref) => CategoriasRescateApi());

final categoriasRescateProvider =
    FutureProvider.autoDispose<List<CategoriaRescate>>((ref) async {
  final api = ref.read(categoriasRescateApiProvider);
  final data = await api.listar();
  return data.map((e) => CategoriaRescate.fromJson(e)).toList();
});

// ============================================================
// REPORTES
// ============================================================

final reportesRescateApiProvider = Provider((ref) => ReportesRescateApi());

final reportesRescateProvider =
    FutureProvider.autoDispose<List<ReporteRescate>>((ref) async {
  final api = ref.read(reportesRescateApiProvider);
  final data = await api.listar();
  return data.map((e) => ReporteRescate.fromJson(e)).toList();
});

final misReportesProvider =
    FutureProvider.autoDispose<List<ReporteRescate>>((ref) async {
  final api = ref.read(reportesRescateApiProvider);
  final data = await api.misReportes();
  return data.map((e) => ReporteRescate.fromJson(e)).toList();
});

final reporteDetalleProvider =
    FutureProvider.autoDispose.family<ReporteRescate, String>((ref, id) async {
  final api = ref.read(reportesRescateApiProvider);
  final data = await api.obtener(id);
  return ReporteRescate.fromJson(data);
});

final estadisticasRescateProvider =
    FutureProvider.autoDispose<Map<String, dynamic>>((ref) async {
  final api = ref.read(reportesRescateApiProvider);
  return await api.estadisticas();
});