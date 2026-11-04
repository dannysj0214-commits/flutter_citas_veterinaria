class CitaModel {
  final String id;
  final String fecha;
  final String hora;
  final String estado;
  final String motivo;
  final String servicio;
  final String notas;
  final dynamic idCliente;
  final dynamic idProfesional;
  final DateTime? createdAt;

  CitaModel({
    required this.id,
    required this.fecha,
    required this.hora,
    required this.estado,
    required this.motivo,
    required this.servicio,
    required this.notas,
    required this.idCliente,
    required this.idProfesional,
    this.createdAt,
  });

  factory CitaModel.fromJson(Map<String, dynamic> json) {
    return CitaModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      fecha: json['fecha'] ?? '',
      hora: json['hora'] ?? '',
      estado: json['estado'] ?? 'pendiente',
      motivo: json['motivo'] ?? '',
      servicio: json['servicio'] ?? '',
      notas: json['notas'] ?? '',
      idCliente: json['id_cliente'],
      idProfesional: json['id_profesional'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'fecha': fecha,
        'hora': hora,
        'estado': estado,
        'motivo': motivo,
        'servicio': servicio,
        'notas': notas,
        'id_cliente': _idFrom(idCliente),
        'id_profesional': _idFrom(idProfesional),
      };

  dynamic _idFrom(dynamic value) {
    if (value is String) return value;
    if (value is Map) return value['_id']?.toString();
    return value;
  }

  String get clienteNombre {
    if (idCliente is Map) return idCliente['nombre'] ?? '';
    return '';
  }

  String get clienteTelefono {
    if (idCliente is Map) return idCliente['telefono'] ?? '';
    return '';
  }

  String get profesionalNombre {
    if (idProfesional is Map) return idProfesional['nombre'] ?? '';
    return '';
  }

  String get profesionalEspecialidad {
    if (idProfesional is Map) return idProfesional['especialidad'] ?? '';
    return '';
  }

  bool get isPendiente => estado == 'pendiente';
  bool get isConfirmada => estado == 'confirmada';
  bool get isCompletada => estado == 'completada';
  bool get isCancelada => estado == 'cancelada';
  bool get isRechazada => estado == 'rechazada';

  String get fechaFormateada {
    try {
      final parts = fecha.split('-');
      if (parts.length != 3) return fecha;
      final meses = [
        '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
        'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
      ];
      final mes = int.parse(parts[1]);
      return '${parts[2]} ${meses[mes]} ${parts[0]}';
    } catch (_) {
      return fecha;
    }
  }
}