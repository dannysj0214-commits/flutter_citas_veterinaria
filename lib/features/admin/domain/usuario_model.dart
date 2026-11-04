class UsuarioModel {
  final String id;
  final String nombre;
  final String email;
  final String rol;
  final String? telefono;
  final String? especialidad;

  UsuarioModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.telefono,
    this.especialidad,
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      rol: json['rol'] ?? 'cliente',
      telefono: json['telefono'],
      especialidad: json['especialidad'],
    );
  }
}