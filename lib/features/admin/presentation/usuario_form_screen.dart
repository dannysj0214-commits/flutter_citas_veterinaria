import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import 'providers/admin_provider.dart';

class UsuarioFormScreen extends ConsumerStatefulWidget {
  final String? id;
  const UsuarioFormScreen({super.key, this.id});

  @override
  ConsumerState<UsuarioFormScreen> createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends ConsumerState<UsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _especialidadCtrl = TextEditingController();

  String _rol = 'cliente';
  bool _loading = false;
  bool _cargando = false;

  final List<String> _roles = ['admin', 'profesional', 'cliente'];

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _cargarUsuario();
    }
  }

  Future<void> _cargarUsuario() async {
    setState(() => _cargando = true);
    try {
      final usuarios = await ref.read(adminApiProvider).listarUsuarios();
      final u = usuarios.firstWhere(
        (x) => x.id == widget.id,
        orElse: () => throw Exception('Usuario no encontrado'),
      );
      _nombreCtrl.text = u.nombre;
      _emailCtrl.text = u.email;
      _telefonoCtrl.text = u.telefono;
      _rol = u.rol;
      _especialidadCtrl.text = u.especialidad ?? '';
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
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _telefonoCtrl.dispose();
    _especialidadCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      final api = ref.read(adminApiProvider);

      if (widget.id != null) {
        await api.actualizarUsuario(
          widget.id!,
          nombre: _nombreCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          telefono: _telefonoCtrl.text.trim(),
          rol: _rol,
          especialidad: _rol == 'profesional'
              ? _especialidadCtrl.text.trim()
              : null,
        );
      } else {
        await api.crearUsuario(
          nombre: _nombreCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          telefono: _telefonoCtrl.text.trim(),
          rol: _rol,
          especialidad: _rol == 'profesional'
              ? _especialidadCtrl.text.trim()
              : null,
        );
      }

      ref.invalidate(usuariosProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.id != null
                ? 'Usuario actualizado'
                : 'Usuario creado'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/admin/usuarios');
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
    if (_cargando) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final isEdit = widget.id != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Usuario' : 'Nuevo Usuario'),
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
                label: 'Nombre completo',
                hint: 'Ej: Juan Pérez',
                icon: Icons.person_outline,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'El nombre es obligatorio'
                    : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailCtrl,
                label: 'Email',
                hint: 'usuario@email.com',
                icon: Icons.email_outlined,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El email es obligatorio';
                  }
                  if (!v.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              if (!isEdit) ...[
                CustomTextField(
                  controller: _passwordCtrl,
                  label: 'Contraseña',
                  hint: 'Mínimo 6 caracteres',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) => v == null || v.length < 6
                      ? 'Mínimo 6 caracteres'
                      : null,
                ),
                const SizedBox(height: 16),
              ],
              CustomTextField(
                controller: _telefonoCtrl,
                label: 'Teléfono',
                hint: 'Ej: 3001234567',
                icon: Icons.phone_outlined,
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'El teléfono es obligatorio'
                    : null,
              ),
              const SizedBox(height: 16),
              const Text(
                'Rol',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _rol,
                dropdownColor: AppColors.surface,
                decoration: const InputDecoration(
                  prefixIcon:
                      Icon(Icons.badge_outlined, color: AppColors.accent),
                ),
                items: _roles
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(
                            r.toUpperCase(),
                            style:
                                const TextStyle(color: AppColors.textPrimary),
                          ),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _rol = v!),
              ),
              if (_rol == 'profesional') ...[
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _especialidadCtrl,
                  label: 'Especialidad',
                  hint: 'Ej: Cirugía, Dermatología',
                  icon: Icons.medical_services_outlined,
                ),
              ],
              const SizedBox(height: 32),
              CustomButton(
                text: isEdit ? 'ACTUALIZAR' : 'CREAR USUARIO',
                isLoading: _loading,
                onPressed: _guardar,
              ),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Cancelar',
                outlined: true,
                onPressed: () => context.go('/admin/usuarios'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}