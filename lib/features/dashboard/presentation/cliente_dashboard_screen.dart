import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../citas/presentation/providers/citas_provider.dart';
import '../../rescate/presentation/providers/rescate_provider.dart';
import '../../../shared/widgets/stat_card.dart';
import 'widgets/dashboard_appbar.dart';
import 'widgets/quick_action_button.dart';

class ClienteDashboardScreen extends ConsumerWidget {
  const ClienteDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final citasAsync = ref.watch(citasClienteProvider);
    final reportesAsync = ref.watch(misReportesProvider);

    return Scaffold(
      appBar: const DashboardAppBar(title: 'Panel Cliente'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(citasClienteProvider);
          ref.invalidate(misReportesProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Bienvenido, ${user?.nombre ?? "Cliente"}!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Aquí está el resumen de tu actividad',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),

              citasAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (_, __) => const SizedBox.shrink(),
                data: (citas) {
                  final pendientes = citas.where((c) => c.isPendiente).length;
                  final confirmadas = citas.where((c) => c.isConfirmada).length;
                  final completadas = citas.where((c) => c.isCompletada).length;

                  return GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      StatCard(
                        label: 'Citas Pendientes',
                        value: '$pendientes',
                        icon: Icons.schedule,
                        color: AppColors.estadoPendiente,
                      ),
                      StatCard(
                        label: 'Citas Confirmadas',
                        value: '$confirmadas',
                        icon: Icons.event_available,
                        color: AppColors.estadoConfirmada,
                      ),
                      StatCard(
                        label: 'Citas Completadas',
                        value: '$completadas',
                        icon: Icons.check_circle,
                        color: AppColors.estadoCompletada,
                      ),
                      StatCard(
                        label: 'Mis Reportes',
                        value: reportesAsync.maybeWhen(
                          data: (r) => '${r.length}',
                          orElse: () => '—',
                        ),
                        icon: Icons.pets,
                        color: AppColors.accent,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'Acciones Rápidas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  QuickActionButton(
                    label: 'Agendar Cita',
                    icon: Icons.calendar_month,
                    onTap: () => context.go('/cliente/agendar'),
                  ),
                  QuickActionButton(
                    label: 'Mis Citas',
                    icon: Icons.list_alt,
                    onTap: () => context.go('/cliente/citas'),
                  ),
                  QuickActionButton(
                    label: 'Mis Historias',
                    icon: Icons.medical_information,
                    onTap: () => context.go('/cliente/historias'), // 👈 BOTÓN AQUÍ
                  ),
                  QuickActionButton(
                    label: 'Reportar Rescate',
                    icon: Icons.report_problem,
                    onTap: () => context.go('/cliente/rescate/nuevo'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              QuickActionButton(
                label: 'Mis Reportes de Rescate',
                icon: Icons.pets,
                onTap: () => context.go('/cliente/rescate'),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Próximas Citas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/cliente/citas'),
                    child: const Text(
                      'Ver todas',
                      style: TextStyle(color: AppColors.accentLight),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              citasAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.error_outline,
                          color: AppColors.error, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Error al cargar citas',
                          style: TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                data: (citas) {
                  final proximas = citas
                      .where((c) => c.isPendiente || c.isConfirmada)
                      .take(3)
                      .toList();

                  if (proximas.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.event_busy,
                              size: 40, color: AppColors.textSecondary),
                          SizedBox(height: 8),
                          Text(
                            'No tienes citas próximas',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: proximas.map((cita) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceLight),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 50,
                              decoration: BoxDecoration(
                                color: cita.isPendiente
                                    ? AppColors.estadoPendiente
                                    : AppColors.estadoConfirmada,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cita.motivo,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${cita.fechaFormateada} • ${cita.hora}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              cita.isPendiente
                                  ? Icons.schedule
                                  : Icons.event_available,
                              color: cita.isPendiente
                                  ? AppColors.estadoPendiente
                                  : AppColors.estadoConfirmada,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}