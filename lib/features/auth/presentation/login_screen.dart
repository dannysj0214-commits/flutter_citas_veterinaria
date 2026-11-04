import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import 'providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // 🌟 FUNCIÓN PARA AUTOCOMPLETAR CREDENCIALES
  void _autocompletarCredenciales(String email, String password) {
    setState(() {
      _emailCtrl.text = email;
      _passCtrl.text = password;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final ok = await ref.read(authProvider.notifier).login(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );

    if (!mounted) return;

    if (ok) {
      final user = ref.read(authProvider).user;
      if (user == null) return;
      if (user.isAdmin) {
        context.go('/admin');
      } else if (user.isProfesional) {
        context.go('/profesional');
      } else {
        context.go('/cliente');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // LOGO
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.2),
                          blurRadius: 15,
                          spreadRadius: 3,
                        )
                      ],
                    ),
                    child: const Icon(
                      Icons.pets,
                      size: 50,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // TÍTULOS
                  const Text(
                    'VETERINARIA',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 2,
                    ),
                  ),
                  const Text(
                    'La Voz de los que no tienen voz',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'INICIAR SESIÓN',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // CAMPOS
                  CustomTextField(
                    controller: _emailCtrl,
                    label: 'Email',
                    hint: 'correo@ejemplo.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Ingresa tu email';
                      if (!v.contains('@')) return 'Email inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passCtrl,
                    label: 'Contraseña',
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    obscureText: true,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Ingresa tu contraseña';
                      }
                      if (v.length < 4) return 'Mínimo 4 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // ERROR
                  if (authState.error != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.error),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authState.error!,
                              style: const TextStyle(color: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (authState.error != null) const SizedBox(height: 16),
                  
                  // BOTÓN
                  CustomButton(
                    text: 'INGRESAR',
                    isLoading: authState.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 16),
                  
                  // LINK REGISTRO
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text(
                      '¿No tienes cuenta? Regístrate',
                      style: TextStyle(color: AppColors.accent),
                    ),
                  ),

                  // 🌟 CREDENCIALES DE PRUEBA
                  const SizedBox(height: 24),
                  const Text(
                    'Credenciales de prueba (Demo):',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () => _autocompletarCredenciales('admin@vet.com', 'password123'),
                        icon: const Icon(Icons.admin_panel_settings, size: 16),
                        label: const Text('Admin'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.accent,
                          side: BorderSide(color: AppColors.accent.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _autocompletarCredenciales('vet@vet.com', 'password123'),
                        icon: const Icon(Icons.medical_services, size: 16),
                        label: const Text('Profesional'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.success,
                          side: BorderSide(color: AppColors.success.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => _autocompletarCredenciales('Dannysj0214@gmail.com', '123456789'),
                        icon: const Icon(Icons.person, size: 16),
                        label: const Text('Cliente'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.warning,
                          side: BorderSide(color: AppColors.warning.withValues(alpha: 0.5)),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Text(
                    '© 2026 Universidad de Cartagena',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}