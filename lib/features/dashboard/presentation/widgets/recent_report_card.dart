import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class RecentReportCard extends StatelessWidget {
  final String titulo;
  final String categoria;
  final String estado;
  final String ubicacion;
  final Color categoriaColor;
  final String id;

  const RecentReportCard({
    super.key,
    required this.titulo,
    required this.categoria,
    required this.estado,
    required this.ubicacion,
    required this.categoriaColor,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.surfaceLight),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: categoriaColor.withValues(alpha: 0.2),
          child: Icon(Icons.pets, color: categoriaColor, size: 20),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.textPrimary),
        ),
        subtitle: Row(
          children: [
            Text(categoria, style: TextStyle(color: categoriaColor, fontSize: 11, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Text('• $estado', style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        onTap: () => context.go('/reportes/$id'),
      ),
    );
  }
}