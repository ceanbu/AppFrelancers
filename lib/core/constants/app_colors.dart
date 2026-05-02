import 'package:flutter/material.dart';

/// Paleta de colores de WorkFlex
/// Extraída directamente del archivo Figma (Empleador + Freelancer)
class AppColors {
  AppColors._();

  // ── Colores base del Figma ──────────────────────────
  /// Azul primario — botones, acciones, links
  static const Color primary = Color(0xFF0A78ED);
  static const Color primaryLight = Color(0xFF3D95F4);
  static const Color primaryDark = Color(0xFF0860C0);

  /// Texto principal — casi negro
  static const Color textPrimary = Color(0xFF121417);

  /// Texto secundario / iconos — gris azulado
  static const Color textSecondary = Color(0xFF61758A);

  /// Fondo general de pantallas
  static const Color background = Color(0xFFF0F2F5);

  /// Superficie limpia — cards, modals, inputs
  static const Color surface = Color(0xFFFFFFFF);

  /// Superficie variante — inputs filled, chips
  static const Color surfaceVariant = Color(0xFFF0F2F5);

  // ── Derivados (no están en Figma, inferidos) ────────
  static const Color textHint = Color(0xFFADB8C6);

  // Estados semánticos
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0A78ED); // mismo que primary

  // Status de vacantes
  static const Color statusOpen = Color(0xFF22C55E);
  static const Color statusPaused = Color(0xFFF59E0B);
  static const Color statusFilled = Color(0xFF61758A);
  static const Color statusClosed = Color(0xFFEF4444);

  // Bordes
  static const Color border = Color(0xFFE4E9F0);
  static const Color borderFocus = Color(0xFF0A78ED);

  // Overlay
  static const Color overlay = Color(0x80121417);
}
