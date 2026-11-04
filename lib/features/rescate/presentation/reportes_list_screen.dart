import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/providers/auth_provider.dart'; // 🌟 Importante para saber el rol
import '../domain/reporte_rescate_model.dart';
import 'providers/rescate_provider.dart';

class ReportesListScreen extends ConsumerStatefulWidget {
  const ReportesListScreen({super.key});

  @override
  ConsumerState<ReportesListScreen> createState() => _ReportesListScreenState();
}

class _ReportesListScreenState extends ConsumerState<ReportesListScreen> {
  String? _categoriaFiltro;
  String? _estadoFiltro;
  final _searchCtrl = TextEditingController();
  String _busqueda = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _parseColor(String hex) {
    try {
      final h = hex.replaceFirst('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return AppColors.accent;
    }
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'activo': return AppColors.warning;
      case 'en_proceso': return AppColors.info;
      case 'resuelto': return AppColors.success;
      case 'cerrado': return AppColors.textSecondary;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).user;
    final reportesAsync = ref.watch(reportesRescateProvider);
    final categoriasAsync = ref.watch(categoriasRescateProvider);
    final esCliente = user?.rol == 'cliente';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidencias y Rescates'),
        // 🌟 BOTÓN DE RETROCESO AGREGADO
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (user?.rol == 'admin') {
              context.go('/admin');
            } else if (user?.rol == 'profesional') {
              context.go('/profesional');
            } else {
              context.go('/cliente');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(reportesRescateProvider),
          ),
        ],
      ),
      floatingActionButton: esCliente
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/cliente/rescate/nuevo'),
              icon: const Icon(Icons.add),
              label: const Text('Reportar'),
              backgroundColor: AppColors.accent,
            )
          : null,
      body: Column(
        children: [
          // 🌟 ENCABEZADO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
            color: AppColors.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gestión de Incidencias',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  esCliente ? 'Tus reportes y avistamientos' : 'Control y seguimiento de casos reportados',
                  style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),

          // 🌟 BUSCADOR
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Buscar por título, descripción o ubicación...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                suffixIcon: _busqueda.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _busqueda = '');
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                setState(() => _busqueda = val.toLowerCase());
              },
            ),
          ),

          // 🌟 FILTROS
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            color: AppColors.surface,
            child: Row(
              children: [
                Expanded(
                  child: categoriasAsync.maybeWhen(
                    data: (cats) => DropdownButtonFormField<String>(
                      initialValue: _categoriaFiltro,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        hintText: 'Todas las categorías',
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        prefixIcon: Icon(Icons.category, size: 20),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('Todas')),
                        ...cats.map((c) => DropdownMenuItem(
                          value: c.id,
                          child: Row(
                            children: [
                              Container(width: 10, height: 10, decoration: BoxDecoration(color: _parseColor(c.color), shape: BoxShape.circle)),
                              const SizedBox(width: 8),
                              Text(c.nombre),
                            ],
                          ),
                        )),
                      ],
                      onChanged: (v) => setState(() => _categoriaFiltro = v),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _estadoFiltro,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      hintText: 'Todos los estados',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      prefixIcon: Icon(Icons.flag, size: 20),
                    ),
                    items: const [
                      DropdownMenuItem(value: null, child: Text('Todos')),
                      DropdownMenuItem(value: 'activo', child: Text('Activo')),
                      DropdownMenuItem(value: 'en_proceso', child: Text('En proceso')),
                      DropdownMenuItem(value: 'resuelto', child: Text('Resuelto')),
                      DropdownMenuItem(value: 'cerrado', child: Text('Cerrado')),
                    ],
                    onChanged: (v) => setState(() => _estadoFiltro = v),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // 🌟 LISTA
          Expanded(
            child: reportesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 48),
                    const SizedBox(height: 16),
                    Text('Error: $err', style: const TextStyle(color: AppColors.error)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(reportesRescateProvider),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
              data: (reportes) {
                var filtrados = reportes;
                if (_categoriaFiltro != null) {
                  filtrados = filtrados.where((r) => r.categoriaId == _categoriaFiltro).toList();
                }
                if (_estadoFiltro != null) {
                  filtrados = filtrados.where((r) => r.estado == _estadoFiltro).toList();
                }
                if (_busqueda.isNotEmpty) {
                  filtrados = filtrados.where((r) {
                    return r.titulo.toLowerCase().contains(_busqueda) ||
                           r.descripcion.toLowerCase().contains(_busqueda) ||
                           r.ubicacion.toLowerCase().contains(_busqueda);
                  }).toList();
                }

                if (filtrados.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.pets, size: 64, color: AppColors.textSecondary),
                        SizedBox(height: 16),
                        Text('No hay incidencias reportadas', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(reportesRescateProvider),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtrados.length,
                    itemBuilder: (context, index) {
                      final reporte = filtrados[index];
                      return _ReporteCard(
                        reporte: reporte,
                        estadoColor: _estadoColor(reporte.estado),
                        categoriaColor: _parseColor(reporte.categoriaColor),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 🌟 TARJETA DE INCIDENCIA
class _ReporteCard extends StatelessWidget {
  final ReporteRescate reporte;
  final Color estadoColor;
  final Color categoriaColor;

  const _ReporteCard({
    required this.reporte,
    required this.estadoColor,
    required this.categoriaColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: categoriaColor.withValues(alpha: 0.5), width: 1.5),
      ),
      child: InkWell(
        onTap: () => context.go('/reportes/${reporte.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: categoriaColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.pets, color: categoriaColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          reporte.categoriaNombre,
                          style: TextStyle(color: categoriaColor, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: estadoColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      reporte.estado.toUpperCase(),
                      style: TextStyle(color: estadoColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                reporte.titulo,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                reporte.descripcion,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      reporte.ubicacion,
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}