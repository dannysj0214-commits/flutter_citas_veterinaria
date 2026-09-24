class ReporteRescate {
  final String id;
  final String titulo;
  final String descripcion;
  final dynamic categoria;
  final String especie;
  final String raza;
  final String colorPelaje;
  final String tamanio;
  final String ubicacion;
  final double? latitud;
  final double? longitud;
  final List<String> fotos;
  final String estado;
  final String contactoNombre;
  final String contactoTelefono;
  final String contactoEmail;
  final dynamic idUsuario;
  final List<Seguimiento> seguimientos;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReporteRescate({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.especie,
    required this.raza,
    required this.colorPelaje,
    required this.tamanio,
    required this.ubicacion,
    this.latitud,
    this.longitud,
    required this.fotos,
    required this.estado,
    required this.contactoNombre,
    required this.contactoTelefono,
    required this.contactoEmail,
    required this.idUsuario,
    required this.seguimientos,
    this.createdAt,
    this.updatedAt,
  });

  factory ReporteRescate.fromJson(Map<String, dynamic> json) {
    return ReporteRescate(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      categoria: json['categoria'],
      especie: json['especie'] ?? 'Canino',
      raza: json['raza'] ?? '',
      colorPelaje: json['color_pelaje'] ?? '',
      tamanio: json['tamanio'] ?? 'Mediano',
      ubicacion: json['ubicacion'] ?? '',
      latitud: json['latitud']?.toDouble(),
      longitud: json['longitud']?.toDouble(),
      fotos: List<String>.from(json['fotos'] ?? []),
      estado: json['estado'] ?? 'activo',
      contactoNombre: json['contacto_nombre'] ?? '',
      contactoTelefono: json['contacto_telefono'] ?? '',
      contactoEmail: json['contacto_email'] ?? '',
      idUsuario: json['id_usuario'],
      seguimientos: (json['seguimientos'] as List? ?? [])
          .map((s) => Seguimiento.fromJson(s))
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  String get categoriaNombre {
    if (categoria is Map) return categoria['nombre'] ?? '';
    return '';
  }

  String get categoriaColor {
    if (categoria is Map) return categoria['color'] ?? '#2C3E50';
    return '#2C3E50';
  }

  String get categoriaId {
    if (categoria is String) return categoria;
    if (categoria is Map) return categoria['_id']?.toString() ?? '';
    return '';
  }

  String get usuarioNombre {
    if (idUsuario is Map) return idUsuario['nombre'] ?? '';
    return '';
  }

  String get usuarioTelefono {
    if (idUsuario is Map) return idUsuario['telefono'] ?? '';
    return '';
  }

  Map<String, dynamic> toJson() => {
        'titulo': titulo,
        'descripcion': descripcion,
        'categoria': categoriaId,
        'especie': especie,
        'raza': raza,
        'color_pelaje': colorPelaje,
        'tamanio': tamanio,
        'ubicacion': ubicacion,
        'latitud': latitud,
        'longitud': longitud,
        'fotos': fotos,
        'estado': estado,
        'contacto_nombre': contactoNombre,
        'contacto_telefono': contactoTelefono,
        'contacto_email': contactoEmail,
      };
}

class Seguimiento {
  final String id;
  final String mensaje;
  final DateTime? fecha;
  final dynamic autor;

  Seguimiento({
    required this.id,
    required this.mensaje,
    this.fecha,
    this.autor,
  });

  factory Seguimiento.fromJson(Map<String, dynamic> json) {
    return Seguimiento(
      id: (json['_id'] ?? '').toString(),
      mensaje: json['mensaje'] ?? '',
      fecha: json['fecha'] != null ? DateTime.tryParse(json['fecha']) : null,
      autor: json['autor'],
    );
  }

  String get autorNombre {
    if (autor is Map) return autor['nombre'] ?? '';
    return '';
  }
}