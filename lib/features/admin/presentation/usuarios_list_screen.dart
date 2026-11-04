import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../providers/admin_provider.dart';
import '../domain/usuario_model.dart';

class UsuariosListScreen extends ConsumerWidget {
  const UsuariosListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosAsync = ref.watch(usuariosProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/admin'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(usuariosProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/admin/usuarios/nuevo'),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
        backgroundColor: AppColors.accent,
      ),
      body: usuariosAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text('Error: $err', style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(usuariosProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (usuarios) {
          if (usuarios.isEmpty) {
            return const Center(
              child: Text(
                'No hay usuarios registrados',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(usuariosProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: usuarios.length,
              itemBuilder: (context, index) {
                final u = usuarios[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                      child: Icon(
                        u.rol == 'admin' ? Icons.admin_panel_settings :
                        u.rol == 'profesional' ? Icons.medical_services : Icons.person,
                        color: AppColors.accent,
                      ),
                    ),
                    title: Text(u.nombre, style: const TextStyle(color: AppColors.textPrimary)),
                    subtitle: Text('${u.email} • ${u.rol}', style: const TextStyle(color: AppColors.textSecondary)),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: AppColors.error),
                      onPressed: () {
                        // Aquí iría la lógica para eliminar
                      },
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
}