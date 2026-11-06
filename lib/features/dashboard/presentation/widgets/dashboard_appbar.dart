import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../notificaciones/presentation/providers/notificaciones_provider.dart';
import '../../../notificaciones/domain/notificacion_model.dart';
import '../../../notificaciones/data/notificaciones_api.dart';

class DashboardAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? extraActions;

  const DashboardAppBar({
    super.key,
    required this.title,
    this.extraActions,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final notifsAsync = ref.watch(notificacionesProvider);

    final unreadCount = notifsAsync.maybeWhen(
      data: (notifs) => notifs.where((n) => !n.leido).length,
      orElse: () => 0,
    );

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          if (user != null)
            Text(
              user.nombre,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
      actions: [
        // 🌟 CAMPANA DE NOTIFICACIONES
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                _mostrarNotificaciones(context, ref, notifsAsync);
              },
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
        
        if (extraActions != null) ...extraActions!,
        
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Cerrar sesión',
          onPressed: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.surface,
                title: const Text('Cerrar sesión', style: TextStyle(color: AppColors.textPrimary)),
                content: const Text('¿Seguro que quieres salir?', style: TextStyle(color: AppColors.textSecondary)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancelar', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Salir', style: TextStyle(color: AppColors.error)),
                  ),
                ],
              ),
            );
            if (confirm == true && context.mounted) {
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            }
          },
        ),
      ],
    );
  }

  // 🌟 Ventana modal con la lista de notificaciones
  void _mostrarNotificaciones(BuildContext context, WidgetRef ref, AsyncValue<List<NotificacionModel>> notifsAsync) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.7,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Notificaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    Row(
                      children: [
                        TextButton(
                          onPressed: () async {
                            final api = NotificacionesApi();
                            await api.marcarTodasLeidas();
                            
                            // Refresca la lista y cierra el modal
                            ref.invalidate(notificacionesProvider);
                            if (ctx.mounted) Navigator.pop(ctx);
                            
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Todas marcadas como leídas'), backgroundColor: AppColors.success),
                              );
                            }
                          },
                          child: const Text('Marcar todas', style: TextStyle(color: AppColors.accent, fontSize: 12)),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              
              Expanded(
                child: notifsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e', style: const TextStyle(color: AppColors.error))),
                  data: (notifs) {
                    if (notifs.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.notifications_off_outlined, size: 60, color: AppColors.textSecondary),
                            SizedBox(height: 16),
                            Text('No tienes notificaciones', style: TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: notifs.length,
                      itemBuilder: (context, index) {
                        final n = notifs[index];
                        return ListTile(
                          // 🌟 AL HACER CLIC: MARCAR COMO LEÍDA Y REDIRIGIR
                          onTap: () async {
                            final api = NotificacionesApi();
                            await api.marcarLeida(n.id);
                            
                            if (ctx.mounted) Navigator.pop(ctx); // Cierra el modal
                            
                            // Redirige
                            if (n.link != null && n.link!.isNotEmpty) {
                              if (n.tipo == 'cita') {
                                context.go('/citas/${n.link}');
                              } else {
                                context.go('/reportes/${n.link}');
                              }
                            }
                            
                            // Refresca para actualizar el contador y quitar el punto
                            ref.invalidate(notificacionesProvider);
                          },
                          leading: CircleAvatar(
                            backgroundColor: n.leido ? AppColors.surfaceLight : AppColors.accent.withValues(alpha: 0.2),
                            child: Icon(
                              n.tipo == 'cita' ? Icons.calendar_month : Icons.pets,
                              color: n.leido ? AppColors.textSecondary : AppColors.accent,
                            ),
                          ),
                          title: Text(
                            n.titulo,
                            style: TextStyle(
                              fontWeight: n.leido ? FontWeight.normal : FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(n.mensaje, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          trailing: n.leido ? null : Container(
                            width: 10, height: 10,
                            decoration: const BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}