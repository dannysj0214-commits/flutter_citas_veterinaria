import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/citas_provider.dart';

class DetalleCitaScreen extends ConsumerWidget {
  final String id;

  const DetalleCitaScreen({super.key, required this.id});

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

  Future<void> _cambiarEstado(BuildContext context, WidgetRef ref, String nuevoEstado) async {
    try {
      final api = ref.read(citasApiProvider);
      await api.cambiarEstado(id, nuevoEstado);
      ref.invalidate(citasClienteProvider);
      ref.invalidate(citasProfesionalProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cita marcada como $nuevoEstado'), backgroundColor: AppColors.success),
        );
        
        final user = ref.read(authProvider).user;
        if (user?.rol == 'admin') {
          context.go('/admin');
        } else if (user?.rol == 'profesional') {
          context.go('/profesional');
        } else {
          context.go('/cliente');
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _cancelarCita(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('¿Cancelar cita?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Esta acción no se puede deshacer.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sí, cancelar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final api = ref.read(citasApiProvider);
        await api.cancelar(id);
        ref.invalidate(citasClienteProvider);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cita cancelada'), backgroundColor: AppColors.success),
          );
          context.go('/cliente/citas');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final citasAsync = ref.watch(citasClienteProvider);
    final citasProfAsync = ref.watch(citasProfesionalProvider);
    final user = ref.watch(authProvider).user;
    final esProfesional = user?.rol == 'profesional' || user?.rol == 'admin';

    final citas = esProfesional
        ? citasProfAsync.maybeWhen(data: (d) => d, orElse: () => [])
        : citasAsync.maybeWhen(data: (d) => d, orElse: () => []);

    final cita = citas.firstWhere(
      (c) => c.id == id,
      orElse: () => throw Exception('Cita no encontrada'),
    );

    final color = _estadoColor(cita.estado);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Cita'),
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    cita.motivo,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    cita.estado.toUpperCase(),
                    style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _seccion('Fecha', cita.fechaFormateada),
            _seccion('Hora', cita.hora),
            _seccion('Servicio', cita.servicio),
            if (cita.notas.isNotEmpty) _seccion('Notas', cita.notas),
            const SizedBox(height: 16),
            if (cita.profesionalNombre.isNotEmpty) _seccion('Profesional', 'Dr(a). ${cita.profesionalNombre}'),
            if (cita.clienteNombre.isNotEmpty) _seccion('Cliente', cita.clienteNombre),
            const SizedBox(height: 32),
            
            if (esProfesional && cita.isPendiente) ...[
              const Text('Acciones del profesional', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 12),
              CustomButton(
                text: 'CONFIRMAR CITA',
                onPressed: () => _cambiarEstado(context, ref, 'confirmada'),
              ),
              const SizedBox(height: 8),
              CustomButton(
                text: 'RECHAZAR',
                outlined: true,
                onPressed: () => _cambiarEstado(context, ref, 'rechazada'),
              ),
            ],
            if (esProfesional && cita.isConfirmada) ...[
              CustomButton(
                text: 'MARCAR COMO COMPLETADA',
                onPressed: () => _cambiarEstado(context, ref, 'completada'),
              ),
            ],
            if (!esProfesional && (cita.isPendiente || cita.isConfirmada))
              CustomButton(
                text: 'CANCELAR CITA',
                outlined: true,
                onPressed: () => _cancelarCita(context, ref),
              ),
          ],
        ),
      ),
    );
  }

  Widget _seccion(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(valor, style: const TextStyle(fontSize: 15, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}