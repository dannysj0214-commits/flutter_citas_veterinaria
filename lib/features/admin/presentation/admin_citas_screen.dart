import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../citas/presentation/providers/citas_provider.dart';

class AdminCitasScreen extends ConsumerWidget {
  const AdminCitasScreen({super.key});

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
    // Usamos un provider de citas global (o el del profesional como demo)
    final citasAsync = ref.watch(citasProfesionalProvider); 

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todas las Citas del Sistema'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'), // 🌟 ATRÁS CORREGIDO
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
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
        data: (citas) {
          if (citas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('No hay citas registradas en el sistema', style: TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: citas.length,
            itemBuilder: (context, index) {
              final cita = citas[index];
              final color = _estadoColor(cita.estado);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 4,
                    height: 40,
                    decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
                  ),
                  title: Text(
                    cita.clienteNombre.isNotEmpty ? cita.clienteNombre : 'Cliente',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  subtitle: Text(
                    'Dr(a). ${cita.profesionalNombre} • ${cita.fechaFormateada} ${cita.hora}',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      cita.estado.toUpperCase(),
                      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () => context.go('/citas/${cita.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}