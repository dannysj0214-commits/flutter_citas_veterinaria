import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../providers/citas_provider.dart';

class AgendarCitaScreen extends ConsumerStatefulWidget {
  const AgendarCitaScreen({super.key});

  @override
  ConsumerState<AgendarCitaScreen> createState() => _AgendarCitaScreenState();
}

class _AgendarCitaScreenState extends ConsumerState<AgendarCitaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motivoCtrl = TextEditingController();
  final _servicioCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();

  String? _profesionalId;
  DateTime _fechaSeleccionada = DateTime.now();
  String? _horaSeleccionada;
  bool _loading = false;
  bool _cargandoDisponibles = false;
  List<String> _horasDisponibles = [];

  @override
  void dispose() {
    _motivoCtrl.dispose();
    _servicioCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarHoras() async {
    if (_profesionalId == null) return;
    setState(() {
      _cargandoDisponibles = true;
      _horasDisponibles = [];
      _horaSeleccionada = null;
    });
    try {
      final api = ref.read(citasApiProvider);
      final fechaStr = '${_fechaSeleccionada.year}-${_fechaSeleccionada.month.toString().padLeft(2, '0')}-${_fechaSeleccionada.day.toString().padLeft(2, '0')}';
      final horas = await api.disponibles(_profesionalId!, fechaStr);
      setState(() => _horasDisponibles = horas);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al cargar horas: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _cargandoDisponibles = false);
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: AppColors.accent, onPrimary: Colors.white, surface: AppColors.surface, onSurface: AppColors.textPrimary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _fechaSeleccionada = picked);
      _cargarHoras();
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_profesionalId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona un profesional'), backgroundColor: AppColors.error));
      return;
    }
    if (_horaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecciona una hora'), backgroundColor: AppColors.error));
      return;
    }

    setState(() => _loading = true);
    try {
      final api = ref.read(citasApiProvider);
      final fechaStr = '${_fechaSeleccionada.year}-${_fechaSeleccionada.month.toString().padLeft(2, '0')}-${_fechaSeleccionada.day.toString().padLeft(2, '0')}';
      final data = {
        'fecha': fechaStr,
        'hora': _horaSeleccionada,
        'motivo': _motivoCtrl.text.trim(),
        'servicio': _servicioCtrl.text.trim().isEmpty ? 'Consulta general' : _servicioCtrl.text.trim(),
        'notas': _notasCtrl.text.trim(),
        'id_profesional': _profesionalId,
      };

      await api.crear(data);
      ref.invalidate(citasClienteProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cita agendada exitosamente'), backgroundColor: AppColors.success));
        context.go('/cliente/citas');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profesionalesAsync = ref.watch(profesionalesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar Cita'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/cliente'), // 🌟 Vuelve al panel cliente
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Selecciona profesional', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              profesionalesAsync.when(
                loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
                error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppColors.error)),
                data: (profesionales) {
                  if (profesionales.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                      child: const Text('No hay profesionales disponibles', style: TextStyle(color: AppColors.textSecondary)),
                    );
                  }
                  return Column(
                    children: profesionales.map((p) {
                      final isSelected = _profesionalId == p['_id'];
                      return GestureDetector(
                        onTap: () {
                          setState(() => _profesionalId = p['_id']);
                          _cargarHoras();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: isSelected ? AppColors.accent : AppColors.surfaceLight, width: isSelected ? 2 : 1),
                          ),
                          child: Row(
                            children: [
                              Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSelected ? AppColors.accent : AppColors.textSecondary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(p['nombre'] ?? '', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                                    Text(p['especialidad'] ?? 'General', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 24),
              const Text('Fecha y hora', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _seleccionarFecha,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.accent),
                      const SizedBox(width: 12),
                      Text('${_fechaSeleccionada.day.toString().padLeft(2, '0')}/${_fechaSeleccionada.month.toString().padLeft(2, '0')}/${_fechaSeleccionada.year}', style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                      const Spacer(),
                      const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_cargandoDisponibles)
                const Center(child: CircularProgressIndicator())
              else if (_horasDisponibles.isNotEmpty) ...[
                const Text('Horas disponibles', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _horasDisponibles.map((h) {
                    final isSelected = _horaSeleccionada == h;
                    return GestureDetector(
                      onTap: () => setState(() => _horaSeleccionada = h),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.accent : AppColors.surface,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: isSelected ? AppColors.accent : AppColors.surfaceLight),
                        ),
                        child: Text(h, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600)),
                      ),
                    );
                  }).toList(),
                ),
              ] else if (_profesionalId != null) ...[
                const Text('No hay horas disponibles para esta fecha', style: TextStyle(color: AppColors.warning)),
              ],
              const SizedBox(height: 24),
              CustomTextField(controller: _motivoCtrl, label: 'Motivo de la consulta', hint: 'Ej: Vacunación, control', icon: Icons.medical_services, validator: (v) => v == null || v.trim().isEmpty ? 'El motivo es obligatorio' : null),
              const SizedBox(height: 16),
              CustomTextField(controller: _servicioCtrl, label: 'Servicio (opcional)', hint: 'Ej: Consulta general', icon: Icons.medical_information),
              const SizedBox(height: 16),
              CustomTextField(controller: _notasCtrl, label: 'Notas adicionales (opcional)', hint: 'Detalles importantes', icon: Icons.notes),
              const SizedBox(height: 32),
              CustomButton(text: 'AGENDAR CITA', isLoading: _loading, onPressed: _guardar),
              const SizedBox(height: 12),
              CustomButton(text: 'Cancelar', outlined: true, onPressed: () => context.go('/cliente')),
            ],
          ),
        ),
      ),
    );
  }
}