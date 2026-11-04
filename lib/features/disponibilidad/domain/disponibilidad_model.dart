class Disponibilidad {
  final String id;
  final int diaSemana;
  final String horaInicio;
  final String horaFin;
  final String idProfesional;

  Disponibilidad({
    required this.id,
    required this.diaSemana,
    required this.horaInicio,
    required this.horaFin,
    required this.idProfesional,
  });

  factory Disponibilidad.fromJson(Map<String, dynamic> json) {
    return Disponibilidad(
      id: (json['_id'] ?? '').toString(),
      diaSemana: json['dia_semana'] ?? 0,
      horaInicio: json['hora_inicio'] ?? '',
      horaFin: json['hora_fin'] ?? '',
      idProfesional: (json['id_profesional'] is Map
              ? json['id_profesional']['_id']
              : json['id_profesional'] ?? '')
          .toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'dia_semana': diaSemana,
        'hora_inicio': horaInicio,
        'hora_fin': horaFin,
      };

  String get diaNombre {
    const dias = [
      'Domingo',
      'Lunes',
      'Martes',
      'Miércoles',
      'Jueves',
      'Viernes',
      'Sábado',
    ];
    return dias[diaSemana];
  }
}