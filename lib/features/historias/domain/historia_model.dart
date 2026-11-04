class HistoriaModel {
  final String id;
  final String propietario;
  final String paciente;
  final String especie;
  final String raza;
  final String edad;
  final String peso;
  final String temperatura;
  final String diagnostico;
  final String tratamiento;
  final String medicamentos;
  final String observaciones;
  final String profesional;
  final DateTime? fecha;

  HistoriaModel({
    required this.id,
    required this.propietario,
    required this.paciente,
    required this.especie,
    required this.raza,
    required this.edad,
    required this.peso,
    required this.temperatura,
    required this.diagnostico,
    required this.tratamiento,
    required this.medicamentos,
    required this.observaciones,
    required this.profesional,
    this.fecha,
  });

  factory HistoriaModel.fromJson(Map<String, dynamic> json) {
    return HistoriaModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      propietario: json['propietario'] ?? '',
      paciente: json['paciente'] ?? '',
      especie: json['especie'] ?? '',
      raza: json['raza'] ?? '',
      edad: json['edad'] ?? '',
      peso: json['peso'] ?? '',
      temperatura: json['temperatura'] ?? '',
      diagnostico: json['diagnostico'] ?? '',
      tratamiento: json['tratamiento'] ?? '',
      medicamentos: json['medicamentos'] ?? '',
      observaciones: json['observaciones'] ?? '',
      profesional: json['profesional'] ?? '',
      fecha: json['fecha'] != null ? DateTime.tryParse(json['fecha']) : null,
    );
  }
}