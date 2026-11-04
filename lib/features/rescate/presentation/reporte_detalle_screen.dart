import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/providers/auth_provider.dart'; // 🌟 Para saber el rol
import '../domain/reporte_rescate_model.dart';
import 'providers/rescate_provider.dart';

class ReporteDetalleScreen extends ConsumerStatefulWidget {
  final String id;

  const ReporteDetalleScreen({super.key, required this.id});

  @override
  ConsumerState<ReporteDetalleScreen> createState() => _ReporteDetalleScreenState();
}

class _ReporteDetalleScreenState extends ConsumerState<ReporteDetalleScreen> {
  final _seguimientoCtrl = TextEditingController();
  bool _enviando = false;
  bool _cambiandoEstado = false;

  @override
  void dispose() {
    _seguimientoCtrl.dispose();
    super.dispose();
  }

  Future<void> _agregarSeguimiento() async {
    if (_seguimientoCtrl.text.trim().isEmpty) return;
    setState(() => _enviando = true);
    try {
      final api = ref.read(reportesRescateApiProvider);
      await api.agregarSeguimiento(widget.id, _seguimientoCtrl.text.trim());
      _seguimientoCtrl.clear();
      ref.invalidate(reporteDetalleProvider(widget.id));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Seguimiento agregado'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  // 🌟 NUEVO: Cambiar estado del reporte
  Future<void> _cambiarEstado(String nuevoEstado) async {
    setState(() => _cambiandoEstado = true);
    try {
      final api = ref.read(reportesRescateApiProvider);
      // Asumiendo que tienes un método para actualizar en la API
      await api.actualizar(widget.id, {'estado': nuevoEstado}); 
      ref.invalidate(reporteDetalleProvider(widget.id));
      ref.invalidate(reportesRescateProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Estado cambiado a $nuevoEstado'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _cambiandoEstado = false);
    }
  }

  Color _estadoColor(String estado) {
    switch (estado) {
      case 'activo': return AppColors.warning;
      case 'en_proceso': return AppColors.info;
      case 'resuelto': return AppColors.success;
      case 'cerrado': return AppColors.textSecondary;
      default: return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reporteAsync = ref.watch(reporteDetalleProvider(widget.id));
    final user = ref.watch(authProvider).user;
    final esAdminOProfesional = user?.rol == 'admin' || user?.rol == 'profesional';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Incidencia'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: reporteAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err', style: const TextStyle(color: AppColors.error))),
        data: (reporte) {
          final estadoColor = _estadoColor(reporte.estado);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🌟 ENCABEZADO
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              reporte.categoriaNombre.toUpperCase(),
                              style: const TextStyle(color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: estadoColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              reporte.estado.toUpperCase(),
                              style: TextStyle(color: estadoColor, fontSize: 11, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        reporte.titulo,
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        reporte.descripcion,
                        style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 🌟 CAMBIAR ESTADO (Solo Admin/Profesional)
                if (esAdminOProfesional) ...[
                  const Text('Gestión del Caso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.surfaceLight),
                    ),
                    child: _cambiandoEstado
                        ? const Center(child: CircularProgressIndicator())
                        : Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _estadoBoton('Activo', 'activo', reporte.estado),
                              _estadoBoton('En Proceso', 'en_proceso', reporte.estado),
                              _estadoBoton('Resuelto', 'resuelto', reporte.estado),
                              _estadoBoton('Cerrado', 'cerrado', reporte.estado),
                            ],
                          ),
                  ),
                  const SizedBox(height: 20),
                ],

                // 🌟 INFO MASCOTA
                const Text('Información de la Mascota', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                _infoCard([
                  _filaInfo('Especie', reporte.especie),
                  _filaInfo('Raza', reporte.raza.isEmpty ? 'No especificada' : reporte.raza),
                  _filaInfo('Tamaño', reporte.tamanio),
                  _filaInfo('Ubicación', reporte.ubicacion),
                ]),
                const SizedBox(height: 20),

                // 🌟 CONTACTO
                const Text('Información de Contacto', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                _infoCard([
                  _filaInfo('Nombre', reporte.contactoNombre),
                  _filaInfo('Teléfono', reporte.contactoTelefono),
                  if (reporte.contactoEmail.isNotEmpty) _filaInfo('Email', reporte.contactoEmail),
                ]),
                
                // 🌟 BOTONES DE CONTACTO DIRECTO
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final Uri launchUri = Uri(scheme: 'tel', path: reporte.contactoTelefono);
                          try {
                            if (await canLaunchUrl(launchUri)) {
                              await launchUrl(launchUri);
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Abre la app en tu celular para realizar llamadas.'), backgroundColor: AppColors.warning),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Abre la app en tu celular para realizar llamadas.'), backgroundColor: AppColors.warning),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.phone, size: 18),
                        label: const Text('Llamar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          final Uri launchUri = Uri(
                            scheme: 'https',
                            host: 'wa.me',
                            path: '${reporte.contactoTelefono}?text=Hola, vi tu reporte "${reporte.titulo}" en el sistema de veterinaria.',
                          );
                          try {
                            if (await canLaunchUrl(launchUri)) {
                              await launchUrl(launchUri, mode: LaunchMode.externalApplication);
                            } else {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Abre la app en tu celular para usar WhatsApp.'), backgroundColor: AppColors.warning),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Abre la app en tu celular para usar WhatsApp.'), backgroundColor: AppColors.warning),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.chat, size: 18),
                        label: const Text('WhatsApp'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF25D366),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 🌟 SEGUIMIENTOS
                const Text('Seguimientos del Caso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                if (reporte.seguimientos.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                    child: const Text('No hay seguimientos aún. ¡Sé el primero en aportar información!', style: TextStyle(color: AppColors.textSecondary)),
                  )
                else
                  ...reporte.seguimientos.map((s) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.surfaceLight),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.mensaje, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.person, size: 12, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(
                                  '${s.autorNombre} • ${_formatFecha(s.fecha)}',
                                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                const SizedBox(height: 16),

                // 🌟 AGREGAR SEGUIMIENTO
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _seguimientoCtrl,
                        decoration: InputDecoration(
                          hintText: 'Escribe un seguimiento...',
                          filled: true,
                          fillColor: AppColors.surface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: _enviando
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.send, color: AppColors.accent),
                      onPressed: _enviando ? null : _agregarSeguimiento,
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _estadoBoton(String label, String valor, String estadoActual) {
    final isSelected = estadoActual == valor;
    final color = _estadoColor(valor);
    return ElevatedButton(
      onPressed: isSelected ? null : () => _cambiarEstado(valor),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : color.withValues(alpha: 0.1),
        foregroundColor: isSelected ? Colors.white : color,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _infoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceLight),
      ),
      child: Column(children: children),
    );
  }

  Widget _filaInfo(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 100, child: Text(titulo, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
          Expanded(child: Text(valor, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  String _formatFecha(DateTime? fecha) {
    if (fecha == null) return '';
    final d = fecha.day.toString().padLeft(2, '0');
    final m = fecha.month.toString().padLeft(2, '0');
    final h = fecha.hour.toString().padLeft(2, '0');
    final min = fecha.minute.toString().padLeft(2, '0');
    return '$d/$m $h:$min';
  }
}