class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final String rol;
  final String? especialidad;
  final bool disponible;
  final DateTime? createdAt;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.rol,
    this.especialidad,
    this.disponible = true,
    this.createdAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'] ?? '',
      rol: json['rol'] ?? 'cliente',
      especialidad: json['especialidad'],
      disponible: json['disponible'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'email': email,
        'telefono': telefono,
        'rol': rol,
        if (especialidad != null && especialidad!.isNotEmpty)
          'especialidad': especialidad,
      };
}