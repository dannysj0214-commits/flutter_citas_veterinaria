import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart'; // 🌟 IMPORTANTE PARA SABER EL ROL
import '../../domain/cita_model.dart';
import '../providers/citas_provider.dart';

class CitasProfesionalScreen extends ConsumerWidget {
  const CitasProfesionalScreen({super.key});

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'pendiente': return AppColors.estadoPendiente;
      case 'confirmada': return AppColors.estadoConfirmada;
      case 'completada': return AppColors.estadoCompletada;
      case 'cancelada': return AppColors.estadoCancelada;
      case 'rechazada': return AppColors.estadoRechazada;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citasAsync = ref.watch(citasProfesionalProvider);
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Citas Asignadas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 🌟 Vuelve al panel correcto según el rol
            if (user?.rol == 'admin') {
              context.go('/admin');
            } else {
              context.go('/profesional');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(citasProfesionalProvider),
          ),
        ],
      ),
      body: citasAsync.when(
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
                onPressed: () => ref.invalidate(citasProfesionalProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (citas) {
          if (citas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('No tienes citas asignadas', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(citasProfesionalProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: citas.length,
              itemBuilder: (context, index) {
                final cita = citas[index];
                final color = _estadoColor(cita.estado);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => context.go('/citas/${cita.id}'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 4,
                                height: 40,
                                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(cita.clienteNombre.isNotEmpty ? cita.clienteNombre : 'Cliente', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 16)),
                                    const SizedBox(height: 2),
                                    Text(cita.motivo, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                                    const SizedBox(height: 2),
                                    Text('${cita.fechaFormateada} • ${cita.hora}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(20)),
                                child: Text(cita.estado.toUpperCase(), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          if (cita.isPendiente) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      try {
                                        await ref.read(citasApiProvider).cambiarEstado(cita.id, 'confirmada');
                                        ref.invalidate(citasProfesionalProvider);
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
                                        }
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                                    child: const Text('Confirmar', style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      try {
                                        await ref.read(citasApiProvider).cambiarEstado(cita.id, 'rechazada');
                                        ref.invalidate(citasProfesionalProvider);
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
                                        }
                                      }
                                    },
                                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error)),
                                    child: const Text('Rechazar', style: TextStyle(color: AppColors.error, fontSize: 12)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}