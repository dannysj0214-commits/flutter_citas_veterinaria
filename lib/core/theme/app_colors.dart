import 'package:flutter/material.dart';

class AppColors {
  // Colores exactos del TCC (tema oscuro)
  static const Color background = Color(0xFF000000);      // Negro
  static const Color surface = Color(0xFF1A1A1A);         // Gris oscuro
  static const Color surfaceLight = Color(0xFF2A2A2A);    // Gris medio
  static const Color textPrimary = Color(0xFFFFFFFF);     // Blanco
  static const Color textSecondary = Color(0xFF999999);   // Gris claro
  static const Color accent = Color(0xFF2C3E50);          // Azul grisáceo
  static const Color accentLight = Color(0xFF3E5871);     // Azul más claro

  // Estados de cita
  static const Color estadoPendiente = Color(0xFFFFC107);   // Amarillo
  static const Color estadoConfirmada = Color(0xFF2196F3);  // Azul
  static const Color estadoCompletada = Color(0xFF4CAF50);  // Verde
  static const Color estadoCancelada = Color(0xFFF44336);   // Rojo
  static const Color estadoRechazada = Color(0xFF9E9E9E);   // Gris

  // Feedback
  static const Color error = Color(0xFFF44336);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color info = Color(0xFF2196F3);
}