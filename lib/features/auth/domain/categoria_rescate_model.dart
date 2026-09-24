class CategoriaRescate {
  final String id;
  final String nombre;
  final String descripcion;
  final String icono;
  final String color;
  final bool activa;

  CategoriaRescate({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.icono,
    required this.color,
    required this.activa,
  });

  factory CategoriaRescate.fromJson(Map<String, dynamic> json) {
    return CategoriaRescate(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      nombre: json['nombre'] ?? '',
      descripcion: json['descripcion'] ?? '',
      icono: json['icono'] ?? 'pets',
      color: json['color'] ?? '#2C3E50',
      activa: json['activa'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'descripcion': descripcion,
        'icono': icono,
        'color': color,
        'activa': activa,
      };
}