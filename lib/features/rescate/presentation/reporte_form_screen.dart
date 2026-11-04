import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../domain/categoria_rescate_model.dart';
import 'providers/rescate_provider.dart';

class ReporteFormScreen extends ConsumerStatefulWidget {
  const ReporteFormScreen({super.key});

  @override
  ConsumerState<ReporteFormScreen> createState() => _ReporteFormScreenState();
}

class _ReporteFormScreenState extends ConsumerState<ReporteFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  final _contactoNombreCtrl = TextEditingController();
  final _contactoTelefonoCtrl = TextEditingController();
  final _contactoEmailCtrl = TextEditingController();

  String? _categoriaId;
  String _especie = 'Canino';
  String _tamanio = 'Mediano';
  String _raza = '';
  String _colorPelaje = '';
  bool _loading = false;

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _ubicacionCtrl.dispose();
    _contactoNombreCtrl.dispose();
    _contactoTelefonoCtrl.dispose();
    _contactoEmailCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una categoría'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final api = ref.read(reportesRescateApiProvider);
      final data = {
        'titulo': _tituloCtrl.text.trim(),
        'descripcion': _descCtrl.text.trim(),
        'categoria': _categoriaId,
        'especie': _especie,
        'raza': _raza,
        'color_pelaje': _colorPelaje,
        'tamanio': _tamanio,
        'ubicacion': _ubicacionCtrl.text.trim(),
        'contacto_nombre': _contactoNombreCtrl.text.trim(),
        'contacto_telefono': _contactoTelefonoCtrl.text.trim(),
        'contacto_email': _contactoEmailCtrl.text.trim(),
      };

      await api.crear(data);
      ref.invalidate(reportesRescateProvider);
      ref.invalidate(misReportesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte creado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/cliente/rescate');
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
    final categoriasAsync = ref.watch(categoriasRescateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reportar Rescate')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información del Rescate',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Categoría
              categoriasAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const SizedBox.shrink(),
                data: (cats) => DropdownButtonFormField<String>(
                  value: _categoriaId,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: cats.map((CategoriaRescate c) {
                    return DropdownMenuItem<String>(
                      value: c.id,
                      child: Text(c.nombre),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _categoriaId = v),
                  validator: (v) => v == null ? 'Selecciona una categoría' : null,
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _tituloCtrl,
                label: 'Título',
                hint: 'Ej: Perro perdido en el centro',
                icon: Icons.title,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'El título es obligatorio'
                    : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _descCtrl,
                label: 'Descripción',
                hint: 'Describe la mascota y la situación',
                icon: Icons.description,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'La descripción es obligatoria'
                    : null,
              ),
              const SizedBox(height: 16),

              // Especie
              DropdownButtonFormField<String>(
                value: _especie,
                decoration: const InputDecoration(
                  labelText: 'Especie',
                  prefixIcon: Icon(Icons.pets),
                ),
                items: const [
                  DropdownMenuItem(value: 'Canino', child: Text('Canino')),
                  DropdownMenuItem(value: 'Felino', child: Text('Felino')),
                  DropdownMenuItem(value: 'Ave', child: Text('Ave')),
                  DropdownMenuItem(value: 'Roedor', child: Text('Roedor')),
                  DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                ],
                onChanged: (v) => setState(() => _especie = v ?? 'Canino'),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: TextEditingController(text: _raza),
                      label: 'Raza',
                      hint: 'Ej: Labrador',
                      icon: Icons.pets,
                      validator: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _tamanio,
                      decoration: const InputDecoration(
                        labelText: 'Tamaño',
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Pequeño', child: Text('Pequeño')),
                        DropdownMenuItem(
                            value: 'Mediano', child: Text('Mediano')),
                        DropdownMenuItem(
                            value: 'Grande', child: Text('Grande')),
                      ],
                      onChanged: (v) => setState(() => _tamanio = v ?? 'Mediano'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _ubicacionCtrl,
                label: 'Ubicación',
                hint: 'Dirección o lugar donde se vio/vio por última vez',
                icon: Icons.location_on,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'La ubicación es obligatoria'
                    : null,
              ),
              const SizedBox(height: 24),

              const Text(
                'Contacto',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _contactoNombreCtrl,
                label: 'Nombre de contacto',
                hint: 'Tu nombre',
                icon: Icons.person,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'El nombre es obligatorio'
                    : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _contactoTelefonoCtrl,
                label: 'Teléfono',
                hint: '3001234567',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'El teléfono es obligatorio'
                    : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _contactoEmailCtrl,
                label: 'Email (opcional)',
                hint: 'correo@ejemplo.com',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: null,
              ),
              const SizedBox(height: 32),

              CustomButton(
                text: 'CREAR REPORTE',
                isLoading: _loading,
                onPressed: _guardar,
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Cancelar',
                outlined: true,
                onPressed: () => context.go('/cliente/rescate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}