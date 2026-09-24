class UserModel {
  final String id;
  final String nombre;
  final String email;
  final String rol;
  final String? telefono;
  final String? especialidad;
  final bool? disponible;

  UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.rol,
    this.telefono,
    this.especialidad,
    this.disponible,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      // El login devuelve 'id', /profile devuelve '_id'
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      nombre: json['nombre'] ?? '',
      email: json['email'] ?? '',
      rol: json['rol'] ?? 'cliente',
      telefono: json['telefono'],
      especialidad: json['especialidad'],
      disponible: json['disponible'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'email': email,
        'rol': rol,
        'telefono': telefono,
        'especialidad': especialidad,
        'disponible': disponible,
      };

  bool get isAdmin => rol == 'admin';
  bool get isProfesional => rol == 'profesional';
  bool get isCliente => rol == 'cliente';
}