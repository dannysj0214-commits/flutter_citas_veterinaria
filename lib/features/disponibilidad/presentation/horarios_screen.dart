import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../domain/disponibilidad_model.dart';
import 'providers/disponibilidad_provider.dart';

class HorariosScreen extends ConsumerWidget {
  const HorariosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horariosAsync = ref.watch(misHorariosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Horarios'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/profesional'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(misHorariosProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
        backgroundColor: AppColors.accent,
      ),
      body: horariosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text('Error: $err',
                  style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(misHorariosProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (horarios) {
          if (horarios.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule,
                      size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text(
                    'No has configurado horarios',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Toca "Agregar" para empezar',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          // Ordenar por día
          final ordenados = [...horarios]
            ..sort((a, b) => a.diaSemana.compareTo(b.diaSemana));

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(misHorariosProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: ordenados.length,
              itemBuilder: (context, index) {
                final horario = ordenados[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                      child: const Icon(Icons.schedule,
                          color: AppColors.accent),
                    ),
                    title: Text(
                      horario.diaNombre,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${horario.horaInicio} - ${horario.horaFin}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () =>
                          _confirmarEliminar(context, ref, horario),
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

  void _confirmarEliminar(
      BuildContext context, WidgetRef ref, Disponibilidad horario) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('¿Eliminar horario?',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Se eliminará el horario del ${horario.diaNombre}.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final api = ref.read(disponibilidadApiProvider);
                await api.eliminar(horario.id);
                ref.invalidate(misHorariosProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Horario eliminado'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Eliminar',
                style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _mostrarFormulario(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => const _FormularioHorario(),
    ).then((_) => ref.invalidate(misHorariosProvider));
  }
}

// ============================================================
// FORMULARIO
// ============================================================

class _FormularioHorario extends ConsumerStatefulWidget {
  const _FormularioHorario();

  @override
  ConsumerState<_FormularioHorario> createState() => _FormularioHorarioState();
}

class _FormularioHorarioState extends ConsumerState<_FormularioHorario> {
  int _diaSemana = 1; // Lunes por defecto
  TimeOfDay _horaInicio = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay _horaFin = const TimeOfDay(hour: 18, minute: 0);
  bool _loading = false;

  Future<void> _seleccionarHora(bool esInicio) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: esInicio ? _horaInicio : _horaFin,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.accent,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (esInicio) {
          _horaInicio = picked;
        } else {
          _horaFin = picked;
        }
      });
    }
  }

  String _formatHora(TimeOfDay hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _guardar() async {
    setState(() => _loading = true);
    try {
      final api = ref.read(disponibilidadApiProvider);
      await api.crear(
        diaSemana: _diaSemana,
        horaInicio: _formatHora(_horaInicio),
        horaFin: _formatHora(_horaFin),
      );
      ref.invalidate(misHorariosProvider);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Horario guardado'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Nuevo Horario',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 24),

          // Día de la semana
          const Text('Día',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          DropdownButtonFormField<int>(
            initialValue: _diaSemana,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.calendar_today),
            ),
            items: const [
              DropdownMenuItem(value: 1, child: Text('Lunes')),
              DropdownMenuItem(value: 2, child: Text('Martes')),
              DropdownMenuItem(value: 3, child: Text('Miércoles')),
              DropdownMenuItem(value: 4, child: Text('Jueves')),
              DropdownMenuItem(value: 5, child: Text('Viernes')),
              DropdownMenuItem(value: 6, child: Text('Sábado')),
              DropdownMenuItem(value: 0, child: Text('Domingo')),
            ],
            onChanged: (v) => setState(() => _diaSemana = v ?? 1),
          ),
          const SizedBox(height: 16),

          // Hora inicio
          const Text('Hora de inicio',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _seleccionarHora(true),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.surfaceLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: AppColors.accent),
                  const SizedBox(width: 12),
                  Text(
                    _formatHora(_horaInicio),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Hora fin
          const Text('Hora de fin',
              style: TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 8),
          InkWell(
            onTap: () => _seleccionarHora(false),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.surfaceLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time, color: AppColors.accent),
                  const SizedBox(width: 12),
                  Text(
                    _formatHora(_horaFin),
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          CustomButton(
            text: 'GUARDAR HORARIO',
            isLoading: _loading,
            onPressed: _guardar,
          ),
        ],
      ),
    );
  }
}