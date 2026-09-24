import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../domain/categoria_rescate_model.dart';
import 'providers/rescate_provider.dart';

class CategoriasListScreen extends ConsumerWidget {
  const CategoriasListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriasAsync = ref.watch(categoriasRescateProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías de Rescate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(categoriasRescateProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/admin/categorias/nueva'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
        backgroundColor: AppColors.accent,
      ),
      body: categoriasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text('Error: $err', style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Reintentar',
                onPressed: () => ref.invalidate(categoriasRescateProvider),
              ),
            ],
          ),
        ),
        data: (categorias) {
          if (categorias.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.category_outlined, size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text(
                    'No hay categorías aún',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(categoriasRescateProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                final cat = categorias[index];
                return _CategoriaCard(categoria: cat);
              },
            ),
          );
        },
      ),
    );
  }
}

class _CategoriaCard extends ConsumerWidget {
  final CategoriaRescate categoria;

  const _CategoriaCard({required this.categoria});

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
  Widget build(BuildContext context, WidgetRef ref) {
    final color = _parseColor(categoria.color);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(_parseIcon(categoria.icono), color: color),
        ),
        title: Text(
          categoria.nombre,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          categoria.descripcion,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.accent),
              onPressed: () => context.go('/admin/categorias/${categoria.id}/editar'),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _confirmarEliminar(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('¿Eliminar categoría?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Se eliminará "${categoria.nombre}". Esta acción no se puede deshacer.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(categoriasRescateApiProvider).eliminar(categoria.id);
                ref.invalidate(categoriasRescateProvider);
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(
                      content: Text('Categoría eliminada'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}