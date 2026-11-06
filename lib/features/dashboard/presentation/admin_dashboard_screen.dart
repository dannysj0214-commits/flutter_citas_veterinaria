import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../admin/presentation/providers/estadisticas_provider.dart'; // 🌟 RUTA CORREGIDA
import '../../rescate/presentation/providers/rescate_provider.dart';
import '../../../shared/widgets/stat_card.dart';
import 'widgets/dashboard_appbar.dart';
import 'widgets/modern_action_card.dart';
import 'widgets/recent_report_card.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final statsAsync = ref.watch(estadisticasProvider);
    final reportesAsync = ref.watch(reportesRescateProvider);

    return Scaffold(
      appBar: const DashboardAppBar(title: 'Panel Administrador'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(estadisticasProvider);
          ref.invalidate(reportesRescateProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Bienvenido, ${user?.nombre ?? "Admin"}!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Resumen en tiempo real del sistema',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              // Cuadros de Resumen
              statsAsync.when(
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator())),
                error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppColors.error)),
                data: (stats) => Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: StatCard(label: 'Usuarios', value: '${stats.totalUsuarios}', icon: Icons.people, color: AppColors.accent)),
                        const SizedBox(width: 12),
                        Expanded(child: StatCard(label: 'Citas Totales', value: '${stats.totalCitas}', icon: Icons.calendar_today, color: AppColors.estadoConfirmada)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: StatCard(label: 'Pendientes', value: '${stats.pendientes}', icon: Icons.schedule, color: AppColors.estadoPendiente)),
                        const SizedBox(width: 12),
                        Expanded(child: StatCard(label: 'Completadas', value: '${stats.completadas}', icon: Icons.check_circle, color: AppColors.estadoCompletada)),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // GRÁFICA DE PASTEL
                    const Text(
                      'Distribución de Citas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 220,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 40,
                                sections: [
                                  PieChartSectionData(value: stats.pendientes.toDouble(), color: AppColors.estadoPendiente, title: '${stats.pendientes}', radius: 50, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  PieChartSectionData(value: stats.confirmadas.toDouble(), color: AppColors.estadoConfirmada, title: '${stats.confirmadas}', radius: 50, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  PieChartSectionData(value: stats.completadas.toDouble(), color: AppColors.estadoCompletada, title: '${stats.completadas}', radius: 50, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  PieChartSectionData(value: stats.canceladas.toDouble(), color: AppColors.estadoCancelada, title: '${stats.canceladas}', radius: 50, titleStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _leyenda(AppColors.estadoPendiente, 'Pendientes'),
                              _leyenda(AppColors.estadoConfirmada, 'Confirmadas'),
                              _leyenda(AppColors.estadoCompletada, 'Completadas'),
                              _leyenda(AppColors.estadoCancelada, 'Canceladas'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Últimos Reportes de Rescate
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Últimos Reportes de Rescate',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  TextButton(
                    onPressed: () => context.go('/admin/reportes'),
                    child: const Text('Ver todos', style: TextStyle(color: AppColors.accent)),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              reportesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => const SizedBox.shrink(),
                data: (reportes) {
                  if (reportes.isEmpty) {
                    return const Text('No hay reportes recientes', style: TextStyle(color: AppColors.textSecondary));
                  }
                  final recientes = reportes.take(3).toList();
                  return Column(
                    children: recientes.map((r) {
                      return RecentReportCard(
                        id: r.id,
                        titulo: r.titulo,
                        categoria: r.categoriaNombre,
                        estado: r.estado,
                        ubicacion: r.ubicacion,
                        categoriaColor: _parseColor(r.categoriaColor),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Botones de Gestión
              const Text(
                'Gestión del Sistema',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  ModernActionCard(title: 'Usuarios', icon: Icons.people, color: AppColors.accent, onTap: () => context.go('/admin/usuarios')),
                  ModernActionCard(title: 'Categorías', icon: Icons.category, color: AppColors.success, onTap: () => context.go('/admin/categorias')),
                  ModernActionCard(title: 'Reportes Rescate', icon: Icons.pets, color: AppColors.warning, onTap: () => context.go('/admin/reportes')),
                  ModernActionCard(title: 'Ver Citas', icon: Icons.calendar_month, color: AppColors.info, onTap: () => context.go('/admin/citas')),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leyenda(Color color, String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text(texto, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Color _parseColor(String hex) {
    try {
      final h = hex.replaceFirst('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return AppColors.accent;
    }
  }
}