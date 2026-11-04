import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_textfield.dart';
import '../providers/admin_provider.dart';

class UsuarioFormScreen extends ConsumerStatefulWidget {
  const UsuarioFormScreen({super.key});

  @override
  ConsumerState<UsuarioFormScreen> createState() => _UsuarioFormScreenState();
}

class _UsuarioFormScreenState extends ConsumerState<UsuarioFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _especialidadCtrl = TextEditingController();
  
  String _rol = 'cliente';
  bool _loading = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _telefonoCtrl.dispose();
    _especialidadCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final api = ref.read(adminApiProvider);
      await api.crearUsuario({
        'nombre': _nombreCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'password': _passCtrl.text,
        'telefono': _telefonoCtrl.text.trim(),
        'rol': _rol,
        'especialidad': _rol == 'profesional' ? _especialidadCtrl.text.trim() : null,
      });

      ref.invalidate(usuariosProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuario creado exitosamente'), backgroundColor: AppColors.success),
        );
        context.go('/admin/usuarios');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Usuario'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin/usuarios'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nombreCtrl,
                label: 'Nombre completo',
                hint: 'Ej: Dr. Carlos',
                icon: Icons.person,
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _emailCtrl,
                label: 'Email',
                hint: 'correo@ejemplo.com',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (!v.contains('@')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passCtrl,
                label: 'Contraseña',
                hint: '••••••••',
                icon: Icons.lock,
                obscureText: true,
                validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _telefonoCtrl,
                label: 'Teléfono',
                hint: '3001234567',
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              
              // Dropdown de Rol
              DropdownButtonFormField<String>(
                initialValue: _rol,
                decoration: const InputDecoration(
                  labelText: 'Rol',
                  prefixIcon: Icon(Icons.badge),
                ),
                items: const [
                  DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
                  DropdownMenuItem(value: 'profesional', child: Text('Profesional')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                ],
                onChanged: (v) => setState(() => _rol = v ?? 'cliente'),
              ),
              const SizedBox(height: 16),
              
              // Especialidad (solo si es profesional)
              if (_rol == 'profesional')
                CustomTextField(
                  controller: _especialidadCtrl,
                  label: 'Especialidad',
                  hint: 'Ej: Medicina General',
                  icon: Icons.medical_services,
                ),
              if (_rol == 'profesional') const SizedBox(height: 16),
              
              const SizedBox(height: 24),
              CustomButton(
                text: 'CREAR USUARIO',
                isLoading: _loading,
                onPressed: _guardar,
              ),
            ],
          ),
        ),
      ),
    );
  }
}