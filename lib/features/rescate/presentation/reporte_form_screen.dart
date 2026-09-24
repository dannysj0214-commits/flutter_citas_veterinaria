import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
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
  final _razaCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  final _contactoNombreCtrl = TextEditingController();
  final _contactoTelefonoCtrl = TextEditingController();
  final _contactoEmailCtrl = TextEditingController();

  String _especie = 'Canino';
  String _tamanio = 'Mediano';
  String? _categoriaId;
  bool _loading = false;

  final List<String> _especies = ['Canino', 'Felino', 'Ave', 'Roedor', 'Otro'];
  final List<String> _tamanios = ['Pequeño', 'Mediano', 'Grande'];

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _razaCtrl.dispose();
    _colorCtrl.dispose();
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
        'raza': _razaCtrl.text.trim(),
        'color_pelaje': _colorCtrl.text.trim(),
        'tamanio': _tamanio,
        'ubicacion': _ubicacionCtrl.text.trim(),
        'contacto_nombre': _contactoNombreCtrl.text.trim(),
        'contacto_telefono': _contactoTelefonoCtrl.text.trim(),
        'contacto_email': _contactoEmailCtrl.text.trim(),
      };

      await api.crear(data);
      ref.invalidate(reportesRescateProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reporte creado'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/admin/reportes');
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
      appBar: AppBar(title: const Text('Nuevo Reporte')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _tituloCtrl,
                label: 'Título',
                hint: 'Ej: Perro perdido en el parque',
                icon: Icons.title,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'El título es obligatorio'
                    : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descCtrl,
                label: 'Descripción',
                hint: 'Describe la situación',
                icon: Icons.description_outlined,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'La descripción es obligatoria'
                    : null,
              ),
              const SizedBox(height: 16),

              // ===== Categoría =====
              const Text(
                'Categoría',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              categoriasAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text(
                  'Error cargando categorías: $e',
                  style: const TextStyle(color: AppColors.error),
                ),
                data: (categorias) => DropdownButtonFormField<String>(
                  initialValue: _categoriaId,
                  dropdownColor: AppColors.surface,
                  decoration: const InputDecoration(
                    hintText: 'Selecciona una categoría',
                    prefixIcon: Icon(Icons.category, color: AppColors.accent),
                  ),
                  items: categorias
                      .map<DropdownMenuItem<String>>((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              c.nombre,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _categoriaId = v),
                ),
              ),
              const SizedBox(height: 16),

              // ===== Especie =====
              const Text(
                'Especie',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _especie,
                dropdownColor: AppColors.surface,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.pets, color: AppColors.accent),
                ),
                items: _especies
                    .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _especie = v!),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _razaCtrl,
                label: 'Raza',
                hint: 'Ej: Labrador',
                icon: Icons.info_outline,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _colorCtrl,
                label: 'Color de pelaje',
                hint: 'Ej: Café con blanco',
                icon: Icons.color_lens_outlined,
              ),
              const SizedBox(height: 16),

              // ===== Tamaño =====
              const Text(
                'Tamaño',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _tamanio,
                dropdownColor: AppColors.surface,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.straighten, color: AppColors.accent),
                ),
                items: _tamanios
                    .map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(
                            t,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _tamanio = v!),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _ubicacionCtrl,
                label: 'Ubicación',
                hint: 'Ej: Parque central, Bogotá',
                icon: Icons.location_on_outlined,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'La ubicación es obligatoria'
                    : null,
              ),
              const SizedBox(height: 24),
              const Divider(color: AppColors.surfaceLight),
              const SizedBox(height: 12),
              const Text(
                'Contacto',
                style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _contactoNombreCtrl,
                label: 'Nombre de contacto',
                hint: 'Tu nombre',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _contactoTelefonoCtrl,
                label: 'Teléfono',
                hint: 'Ej: 3001234567',
                icon: Icons.phone_outlined,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _contactoEmailCtrl,
                label: 'Email',
                hint: 'tu@email.com',
                icon: Icons.email_outlined,
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
                onPressed: () => context.go('/admin/reportes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}