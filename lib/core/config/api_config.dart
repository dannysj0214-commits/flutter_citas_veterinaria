import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  /// URL base del backend, adaptada automáticamente a la plataforma:
  /// - Web (Chrome/Edge):  http://localhost:5000/api
  /// - Android (emulador o celular): http://192.168.101.15:5000/api
  /// - Windows/macOS/Linux: http://localhost:5000/api
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:5000/api';
    }
    if (Platform.isAndroid) {
      // ⚠️ IP LOCAL DE TU PC (para celular físico y emulador)
      return 'http://192.168.101.15:5000/api';
    }
    return 'http://localhost:5000/api';
  }

  // Endpoints Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String profile = '/auth/profile';
  static const String profesionales = '/auth/profesionales';

  // Endpoints Citas
  static const String appointments = '/appointments';
  static const String appointmentsCliente = '/appointments/cliente';
  static const String appointmentsProfesional = '/appointments/profesional';

  // Endpoints Historias
  static const String medicalRecords = '/medical-records';

  // Endpoints Notificaciones
  static const String notifications = '/notifications';

  // Endpoints Reportes
  static const String reportsStats = '/reports/stats';
  static const String reportsPorEstado = '/reports/citas-por-estado';
  static const String reportsPorMes = '/reports/citas-por-mes';

  // Endpoints Admin
  static const String adminUsuarios = '/admin/usuarios';

  // Timeouts (aumentados para evitar el error de conexión)
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}