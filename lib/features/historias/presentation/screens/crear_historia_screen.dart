import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../providers/historias_provider.dart';

class CrearHistoriaScreen extends ConsumerStatefulWidget {
  const CrearHistoriaScreen({super.key});

  @override
  ConsumerState<CrearHistoriaScreen> createState() => _CrearHistoriaScreenState();
}

class _CrearHistoriaScreenState extends ConsumerState<CrearHistoriaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _propietarioCtrl = TextEditingController();
  final _pacienteCtrl = TextEditingController();
  final _especieCtrl = TextEditingController(text: 'Canino');
  final _razaCtrl = TextEditingController();
  final _edadCtrl = TextEditingController();
  final _pesoCtrl = TextEditingController();
  final _tempCtrl = TextEditingController();
  final _diagnosticoCtrl = TextEditingController();
  final _tratamientoCtrl = TextEditingController();
  final _medicamentosCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();
  
  String? _clienteIdSeleccionado;
  bool _loading = false;

  @override
  void dispose() {
    _propietarioCtrl.dispose();
    _pacienteCtrl.dispose();
    _especieCtrl.dispose();
    _razaCtrl.dispose();
    _edadCtrl.dispose();
    _pesoCtrl.dispose();
    _tempCtrl.dispose();
    _diagnosticoCtrl.dispose();
    _tratamientoCtrl.dispose();
    _medicamentosCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_clienteIdSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona un cliente'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final api = ref.read(historiasApiProvider);
      await api.crear({
        'propietario': _propietarioCtrl.text.trim(),
        'paciente': _pacienteCtrl.text.trim(),
        'especie': _especieCtrl.text.trim(),
        'raza': _razaCtrl.text.trim(),
        'edad': _edadCtrl.text.trim(),
        'peso': _pesoCtrl.text.trim(),
        'temperatura': _tempCtrl.text.trim(),
        'diagnostico': _diagnosticoCtrl.text.trim(),
        'tratamiento': _tratamientoCtrl.text.trim(),
        'medicamentos': _medicamentosCtrl.text.trim(),
        'observaciones': _observacionesCtrl.text.trim(),
        'cliente_id': _clienteIdSeleccionado, // 👈 VINCULAMOS AL CLIENTE
      });

      ref.invalidate(historiasProfesionalProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Historia clínica guardada exitosamente'), 
            backgroundColor: AppColors.success
          ),
        );
        context.go('/profesional/historias');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'), 
            backgroundColor: AppColors.error
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos la lista de clientes
    final clientesAsync = ref.watch(clientesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nueva Historia Clínica'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), 
          onPressed: () => context.go('/profesional/historias')
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // 🌟 DROPDOWN DE CLIENTES
              clientesAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Text('Error al cargar clientes: $e', style: const TextStyle(color: AppColors.error)),
                data: (clientes) {
                  if (clientes.isEmpty) {
                    return const Text('No hay clientes registrados', style: TextStyle(color: AppColors.warning));
                  }
                  return DropdownButtonFormField<String>(
                    initialValue: _clienteIdSeleccionado,
                    decoration: const InputDecoration(
                      labelText: 'Cliente (Dueño de la mascota)',
                      prefixIcon: Icon(Icons.person),
                    ),
                    items: clientes.map<DropdownMenuItem<String>>((c) {
                      return DropdownMenuItem<String>(
                        value: c['_id'],
                        child: Text('${c['nombre']} (${c['email']})'),
                      );
                    }).toList(),
                    onChanged: (v) {
                      setState(() {
                        _clienteIdSeleccionado = v;
                        // Autocompletar el propietario con el nombre del cliente
                        final cliente = clientes.firstWhere((c) => c['_id'] == v);
                        _propietarioCtrl.text = cliente['nombre'] ?? '';
                      });
                    },
                    validator: (v) => v == null ? 'Selecciona un cliente' : null,
                  );
                },
              ),
              const SizedBox(height: 12),

              CustomTextField(
                controller: _pacienteCtrl, 
                label: 'Nombre de la Mascota', 
                hint: 'Ej: Firulais', 
                icon: Icons.pets, 
                validator: (v) => v!.isEmpty ? 'Requerido' : null
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _propietarioCtrl, 
                label: 'Propietario', 
                hint: 'Ej: Juan Pérez', 
                icon: Icons.person, 
                validator: (v) => v!.isEmpty ? 'Requerido' : null
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _especieCtrl, 
                      label: 'Especie', 
                      hint: 'Canino', 
                      icon: Icons.category
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _razaCtrl, 
                      label: 'Raza', 
                      hint: 'Ej: Labrador', 
                      icon: Icons.pets
                    )
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _edadCtrl, 
                      label: 'Edad', 
                      hint: 'Ej: 2 años', 
                      icon: Icons.cake
                    )
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _pesoCtrl, 
                      label: 'Peso', 
                      hint: 'Ej: 15 kg', 
                      icon: Icons.monitor_weight
                    )
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _tempCtrl, 
                label: 'Temperatura', 
                hint: 'Ej: 38.5 °C', 
                icon: Icons.thermostat
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _diagnosticoCtrl, 
                label: 'Diagnóstico', 
                hint: 'Detalle del diagnóstico', 
                icon: Icons.medical_services, 
                validator: (v) => v!.isEmpty ? 'Requerido' : null
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _tratamientoCtrl, 
                label: 'Tratamiento', 
                hint: 'Tratamiento indicado', 
                icon: Icons.healing, 
                validator: (v) => v!.isEmpty ? 'Requerido' : null
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _medicamentosCtrl, 
                label: 'Medicamentos', 
                hint: 'Medicamentos recetados', 
                icon: Icons.medication
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _observacionesCtrl, 
                label: 'Observaciones', 
                hint: 'Notas adicionales', 
                icon: Icons.note
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'GUARDAR HISTORIA', 
                isLoading: _loading, 
                onPressed: _guardar
              ),
            ],
          ),
        ),
      ),
    );
  }
}