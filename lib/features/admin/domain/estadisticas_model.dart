class EstadisticasModel {
  final int totalCitas;
  final int pendientes;
  final int confirmadas;
  final int completadas;
  final int canceladas;
  final int totalUsuarios;
  final int totalReportes;

  EstadisticasModel({
    required this.totalCitas,
    required this.pendientes,
    required this.confirmadas,
    required this.completadas,
    required this.canceladas,
    required this.totalUsuarios,
    required this.totalReportes,
  });

  factory EstadisticasModel.fromJson(Map<String, dynamic> json) {
    final citas = json['citas'] ?? {};
    final usuarios = json['usuarios'] ?? {};
    return EstadisticasModel(
      totalCitas: citas['total'] ?? 0,
      pendientes: citas['pendientes'] ?? 0,
      confirmadas: citas['confirmadas'] ?? 0,
      completadas: citas['completadas'] ?? 0,
      canceladas: citas['canceladas'] ?? 0,
      totalUsuarios: (usuarios['clientes'] ?? 0) + (usuarios['profesionales'] ?? 0),
      totalReportes: json['historias'] ?? 0, // Ajusta si tienes un endpoint de reportes
    );
  }
}