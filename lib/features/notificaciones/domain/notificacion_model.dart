class NotificacionModel {
  final String id;
  final String tipo;
  final String titulo;
  final String mensaje;
  final bool leido;
  final String? link; // 🌟 NUEVO CAMPO
  final DateTime? createdAt;

  NotificacionModel({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.mensaje,
    required this.leido,
    this.link,
    this.createdAt,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      id: (json['_id'] ?? '').toString(),
      tipo: json['tipo'] ?? 'sistema',
      titulo: json['titulo'] ?? '',
      mensaje: json['mensaje'] ?? '',
      leido: json['leido'] ?? false,
      link: json['link'], // 🌟 NUEVO CAMPO
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}