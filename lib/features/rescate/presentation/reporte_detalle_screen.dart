import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_textfield.dart';
import '../domain/reporte_rescate_model.dart';
import 'providers/rescate_provider.dart';

class ReporteDetalleScreen extends ConsumerStatefulWidget {
  final String id;
  const ReporteDetalleScreen({super.key, required this.id});

  @override
  ConsumerState<ReporteDetalleScreen> createState() =>
      _ReporteDetalleScreenState();
}

class _ReporteDetalleScreenState extends ConsumerState<ReporteDetalleScreen> {
  final _seguimientoCtrl = TextEditingController();
  bool _enviando = false;

  @override
  void dispose() {
    _seguimientoCtrl.dispose();
    super.dispose();
  }

  Future<void> _agregarSeguimiento() async {
    final texto = _seguimientoCtrl.text.trim();
    if (texto.isEmpty) return;

    setState(() => _enviando = true);
    try {
      await ref
          .read(reportesRescateApiProvider)
          .agregarSeguimiento(widget.id, texto);
      _seguimientoCtrl.clear();
      ref.invalidate(reporteDetalleProvider(widget.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Seguimiento agregado'),
            backgroundColor: AppColors.success,
          ),
        );
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
      if (mounted) setState(() => _enviando = false);
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

  @override
  Widget build(BuildContext context) {
    final detalleAsync = ref.watch(reporteDetalleProvider(widget.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Reporte'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.invalidate(reporteDetalleProvider(widget.id)),
          ),
        ],
      ),
      body: detalleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    color: AppColors.error, size: 48),
                const SizedBox(height: 16),
                Text('Error: $err',
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Reintentar',
                  onPressed: () =>
                      ref.invalidate(reporteDetalleProvider(widget.id)),
                ),
              ],
            ),
          ),
        ),
        data: (reporte) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEncabezado(reporte),
                const SizedBox(height: 16),
                _buildInfoBasica(reporte),
                const SizedBox(height: 16),
                _buildContacto(reporte),
                const SizedBox(height: 16),
                _buildSeguimientos(reporte),
                const SizedBox(height: 24),
                CustomButton(
                  text: 'Volver',
                  outlined: true,
                  onPressed: () => context.go('/admin/reportes'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEncabezado(ReporteRescate r) {
    final color = _parseColor(r.categoriaColor);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(Icons.pets, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    r.titulo,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${r.especie} · ${r.raza.isEmpty ? "Sin raza" : r.raza} · ${r.tamanio}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            _estadoChip(r.estado),
          ],
        ),
      ),
    );
  }

  Widget _estadoChip(String estado) {
    Color color;
    switch (estado) {
      case 'resuelto':
      case 'encontrado':
        color = AppColors.success;
        break;
      case 'en_proceso':
        color = AppColors.accent;
        break;
      case 'cerrado':
        color = AppColors.textSecondary;
        break;
      default:
        color = AppColors.warning;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _buildInfoBasica(ReporteRescate r) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Información',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                )),
            const SizedBox(height: 12),
            _fila('Descripción', r.descripcion),
            _fila('Categoría', r.categoriaNombre),
            _fila('Color de pelaje', r.colorPelaje),
            _fila('Ubicación', r.ubicacion),
            if (r.latitud != null && r.longitud != null)
              _fila('Coordenadas',
                  '${r.latitud!.toStringAsFixed(4)}, ${r.longitud!.toStringAsFixed(4)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildContacto(ReporteRescate r) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Contacto',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                )),
            const SizedBox(height: 12),
            _fila('Nombre', r.contactoNombre),
            _fila('Teléfono', r.contactoTelefono),
            _fila('Email', r.contactoEmail),
          ],
        ),
      ),
    );
  }

  Widget _buildSeguimientos(ReporteRescate r) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timeline, color: AppColors.accent),
                const SizedBox(width: 8),
                Text(
                  'Seguimientos (${r.seguimientos.length})',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (r.seguimientos.isEmpty)
              const Text(
                'Sin seguimientos aún',
                style: TextStyle(color: AppColors.textSecondary),
              )
            else
              ...r.seguimientos.reversed.map((s) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.circle,
                            size: 8, color: AppColors.accent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.mensaje,
                                  style: const TextStyle(
                                      color: AppColors.textPrimary)),
                              const SizedBox(height: 2),
                              Text(
                                '${s.autorNombre} · ${s.fecha?.toString().substring(0, 16) ?? ""}',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  )),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _seguimientoCtrl,
              label: 'Agregar seguimiento',
              hint: 'Escribe una actualización...',
              icon: Icons.edit_note,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'AGREGAR',
              isLoading: _enviando,
              onPressed: _agregarSeguimiento,
            ),
          ],
        ),
      ),
    );
  }

  Widget _fila(String label, String valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              valor.isEmpty ? '-' : valor,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}