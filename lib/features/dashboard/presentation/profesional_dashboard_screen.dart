import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/providers/auth_provider.dart';
import '../../citas/presentation/providers/citas_provider.dart';
import '../../../shared/widgets/stat_card.dart';
import 'widgets/dashboard_appbar.dart';
import 'widgets/quick_action_button.dart';

class ProfesionalDashboardScreen extends ConsumerWidget {
  const ProfesionalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final citasAsync = ref.watch(citasProfesionalProvider);

    return Scaffold(
      appBar: const DashboardAppBar(title: 'Panel Profesional'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(citasProfesionalProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¡Bienvenido, Dr(a). ${user?.nombre ?? "Profesional"}!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Aquí están tus citas asignadas',
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
                        label: 'Pendientes',
                        value: '$pendientes',
                        icon: Icons.schedule,
                        color: AppColors.estadoPendiente,
                      ),
                      StatCard(
                        label: 'Confirmadas',
                        value: '$confirmadas',
                        icon: Icons.event_available,
                        color: AppColors.estadoConfirmada,
                      ),
                      StatCard(
                        label: 'Completadas',
                        value: '$completadas',
                        icon: Icons.check_circle,
                        color: AppColors.estadoCompletada,
                      ),
                      StatCard(
                        label: 'Total',
                        value: '${citas.length}',
                        icon: Icons.list_alt,
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
                    label: 'Mis Citas',
                    icon: Icons.calendar_month,
                    onTap: () => context.go('/profesional/citas'),
                  ),
                  QuickActionButton(
                    label: 'Historias',
                    icon: Icons.medical_information,
                    onTap: () => context.go('/profesional/historias'),
                  ),
                  QuickActionButton(
                    label: 'Mis Servicios',
                    icon: Icons.medical_services,
                    onTap: () => context.go('/profesional/servicios'),
                  ),
                  QuickActionButton(
                    label: 'Horarios',
                    icon: Icons.schedule,
                    onTap: () => context.go('/profesional/horarios'),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                'Citas Pendientes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              citasAsync.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => const SizedBox.shrink(),
                data: (citas) {
                  final pendientes = citas
                      .where((c) => c.isPendiente)
                      .take(5)
                      .toList();

                  if (pendientes.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.check_circle,
                              size: 40, color: AppColors.success),
                          SizedBox(height: 8),
                          Text(
                            'No tienes citas pendientes',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    );
                  }

                  return Column(
                    children: pendientes.map((cita) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.estadoPendiente.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 4,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.estadoPendiente,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    cita.clienteNombre.isEmpty
                                        ? cita.motivo
                                        : cita.clienteNombre,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    cita.motivo,
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${cita.fechaFormateada} • ${cita.hora}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right,
                                color: AppColors.textSecondary),
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