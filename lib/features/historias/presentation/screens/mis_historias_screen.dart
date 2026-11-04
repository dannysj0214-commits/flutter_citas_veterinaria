import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/historias_provider.dart';

class MisHistoriasScreen extends ConsumerWidget {
  const MisHistoriasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final esProfesional = user?.rol == 'profesional' || user?.rol == 'admin';

    // Elige qué provider usar según el rol
    final historiasAsync = esProfesional
        ? ref.watch(historiasProfesionalProvider)
        : ref.watch(historiasClienteProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(esProfesional ? 'Historias Creadas' : 'Mis Historias'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () =>
              context.go(esProfesional ? '/profesional' : '/cliente'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(
              esProfesional
                  ? historiasProfesionalProvider
                  : historiasClienteProvider,
            ),
          ),
        ],
      ),
      // 👇 BOTÓN FLOTANTE AGREGADO AQUÍ 👇
      floatingActionButton: esProfesional
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/profesional/historias/nueva'),
              icon: const Icon(Icons.add),
              label: const Text('Nueva Historia'),
              backgroundColor: AppColors.accent,
            )
          : null,
      // 👆 FIN DEL BOTÓN FLOTANTE 👆
      body: historiasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  color: AppColors.error, size: 48),
              const SizedBox(height: 16),
              Text('Error: $err',
                  style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(
                  esProfesional
                      ? historiasProfesionalProvider
                      : historiasClienteProvider,
                ),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (historias) {
          if (historias.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.medical_information,
                      size: 64, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text(
                    'No hay historias clínicas',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(
              esProfesional
                  ? historiasProfesionalProvider
                  : historiasClienteProvider,
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: historias.length,
              itemBuilder: (context, index) {
                final h = historias[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    iconColor: AppColors.accent,
                    collapsedIconColor: AppColors.textSecondary,
                    title: Text(
                      h.paciente,
                      style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'Propietario: ${h.propietario} • ${h.especie}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _fila('Diagnóstico', h.diagnostico),
                            _fila('Tratamiento', h.tratamiento),
                            _fila('Medicamentos', h.medicamentos),
                            _fila('Observaciones', h.observaciones),
                            _fila('Atendido por', h.profesional),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _fila(String titulo, String valor) {
    if (valor.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold)),
          Text(valor,
              style: const TextStyle(
                  fontSize: 14, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}