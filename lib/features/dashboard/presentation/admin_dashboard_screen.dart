import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/providers/auth_provider.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Administrador'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hola, ${auth.user?.nombre ?? "Admin"} 👋',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Bienvenido al panel de administración',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),

            // ===== SISTEMA VETERINARIO =====
            _seccion('Sistema Veterinario'),
            _accesoCard(
              context,
              icon: Icons.people,
              titulo: 'Gestionar Usuarios',
              subtitulo: 'Crear, editar y eliminar usuarios del sistema',
              ruta: '/admin/usuarios',
            ),
            _accesoCard(
              context,
              icon: Icons.insights,
              titulo: 'Reportes y Estadísticas',
              subtitulo: 'Próximamente',
              ruta: null,
            ),

            const SizedBox(height: 24),

            // ===== MÓDULO DE RESCATE =====
            _seccion('Módulo de Rescate'),
            _accesoCard(
              context,
              icon: Icons.category,
              titulo: 'Categorías de Rescate',
              subtitulo: 'Crear, editar y eliminar categorías',
              ruta: '/admin/categorias',
            ),
            _accesoCard(
              context,
              icon: Icons.report,
              titulo: 'Reportes de Rescate',
              subtitulo: 'Ver y gestionar reportes ciudadanos',
              ruta: '/admin/reportes',
            ),
          ],
        ),
      ),
    );
  }

  Widget _seccion(String titulo) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        titulo,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _accesoCard(
    BuildContext context, {
    required IconData icon,
    required String titulo,
    required String subtitulo,
    required String? ruta,
  }) {
    final activo = ruta != null;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: activo
              ? AppColors.accent.withValues(alpha: 0.2)
              : AppColors.surfaceLight,
          child: Icon(
            icon,
            color: activo ? AppColors.accent : AppColors.textSecondary,
          ),
        ),
        title: Text(
          titulo,
          style: TextStyle(
            color: activo ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitulo,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        trailing: activo
            ? const Icon(Icons.chevron_right, color: AppColors.accent)
            : null,
        onTap: activo ? () => context.go(ruta) : null,
      ),
    );
  }
}