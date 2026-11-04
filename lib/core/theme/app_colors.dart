import 'package:flutter/material.dart';

class AppColors {
  // 🎨 Nueva paleta clara (Salud / Clínica)
  static const Color background = Color(0xFFF5F7FA);      // Blanco hueso (fondo principal)
  static const Color surface = Color(0xFFFFFFFF);         // Blanco puro (tarjetas)
  static const Color surfaceLight = Color(0xFFE3E8EF);    // Gris muy claro (bordes)
  
  static const Color textPrimary = Color(0xFF1E293B);     // Azul muy oscuro (texto principal)
  static const Color textSecondary = Color(0xFF64748B);   // Gris azulado (texto secundario)
  
  static const Color accent = Color(0xFF0284C7);          // Azul cielo fuerte (botones, íconos)
  static const Color accentLight = Color(0xFF38BDF8);     // Azul claro (detalles)

  // Estados de cita (se mantienen vivos para que resalten)
  static const Color estadoPendiente = Color(0xFFF59E0B);   // Ámbar
  static const Color estadoConfirmada = Color(0xFF3B82F6);  // Azul
  static const Color estadoCompletada = Color(0xFF10B981);  // Verde esmeralda
  static const Color estadoCancelada = Color(0xFFEF4444);   // Rojo
  static const Color estadoRechazada = Color(0xFF94A3B8);   // Gris

  // Feedback
  static const Color error = Color(0xFFEF4444);
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);
}