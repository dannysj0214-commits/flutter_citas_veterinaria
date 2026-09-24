import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import 'providers/rescate_provider.dart';

class CategoriaFormScreen extends ConsumerStatefulWidget {
  final String? id;

  const CategoriaFormScreen({super.key, this.id});

  @override
  ConsumerState<CategoriaFormScreen> createState() =>
      _CategoriaFormScreenState();
}

class _CategoriaFormScreenState extends ConsumerState<CategoriaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _icono = 'pets';
  String _color = '#2C3E50';
  bool _loading = false;
  bool _cargando = false;

  final List<String> _iconos = [
    'pets',
    'search',
    'check_circle',
    'home',
    'warning',
    'report',
  ];

  final List<String> _colores = [
    '#2C3E50',
    '#F44336',
    '#4CAF50',
    '#2196F3',
    '#FFC107',
    '#9C27B0',
    '#FF9800',
    '#00BCD4',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _cargarCategoria();
    }
  }

  Future<void> _cargarCategoria() async {
    setState(() => _cargando = true);
    try {
      final api = ref.read(categoriasRescateApiProvider);
      final data = await api.listarTodas();
      for (final item in data) {
        if (item['_id'] == widget.id) {
          _nombreCtrl.text = item['nombre'] ?? '';
          _descCtrl.text = item['descripcion'] ?? '';
          _icono = item['icono'] ?? 'pets';
          _color = item['color'] ?? '#2C3E50';
          break;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final api = ref.read(categoriasRescateApiProvider);
      final data = {
        'nombre': _nombreCtrl.text.trim(),
        'descripcion': _descCtrl.text.trim(),
        'icono': _icono,
        'color': _color,
      };

      if (widget.id != null) {
        await api.actualizar(widget.id!, data);
      } else {
        await api.crear(data);
      }

      ref.invalidate(categoriasRescateProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.id != null
                ? 'Categoría actualizada'
                : 'Categoría creada'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/admin/categorias');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Color _parseColor(String hex) {
    try {
      final h = hex.replaceFirst('#', '');
      return Color(int.parse('FF$h', radix: 16));
    } catch (_) {
      return AppColors.accent;
    }
  }

  IconData _parseIcon(String name) {
    switch (name) {
      case 'search':
        return Icons.search;
      case 'check_circle':
        return Icons.check_circle;
      case 'home':
        return Icons.home;
      case 'warning':
        return Icons.warning;
      case 'report':
        return Icons.report;
      default:
        return Icons.pets;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isEdit = widget.id != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Categoría' : 'Nueva Categoría'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                controller: _nombreCtrl,
                label: 'Nombre',
                hint: 'Ej: Perdida, Encontrada',
                icon: Icons.label_outline,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'El nombre es obligatorio'
                    : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descCtrl,
                label: 'Descripción',
                hint: 'Describe cuándo usar esta categoría',
                icon: Icons.description_outlined,
              ),
              const SizedBox(height: 24),
              const Text(
                'Ícono',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _iconos.map((i) {
                  final selected = _icono == i;
                  return GestureDetector(
                    onTap: () => setState(() => _icono = i),
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color:
                            selected ? AppColors.accent : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColors.accentLight
                              : AppColors.surfaceLight,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _parseIcon(i),
                        color: selected
                            ? Colors.white
                            : AppColors.textSecondary,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Color',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _colores.map((c) {
                  final selected = _color == c;
                  return GestureDetector(
                    onTap: () => setState(() => _color = c),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _parseColor(c),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected
                              ? Colors.white
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check,
                              color: Colors.white, size: 20)
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: isEdit ? 'ACTUALIZAR' : 'CREAR',
                isLoading: _loading,
                onPressed: _guardar,
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Cancelar',
                outlined: true,
                onPressed: () => context.go('/admin/categorias'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}