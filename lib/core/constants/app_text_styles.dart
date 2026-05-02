import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Tipografía: Manrope (extraída de Figma)
/// Regular (400) → cuerpo, 16px, line-height 24
/// Bold (700)    → títulos, 22px, line-height 28
class AppTextStyles {
  AppTextStyles._();

  // ── Títulos — Manrope Bold ───────────────────────────
  static TextStyle get displayLarge => GoogleFonts.manrope(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.25,
        letterSpacing: 0,
      );

  static TextStyle get displayMedium => GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 28 / 22, // line-height 28 del Figma
        letterSpacing: 0,
      );

  static TextStyle get headlineLarge => GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
        letterSpacing: 0,
      );

  static TextStyle get headlineMedium => GoogleFonts.manrope(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.3,
        letterSpacing: 0,
      );

  static TextStyle get titleLarge => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.4,
        letterSpacing: 0,
      );

  static TextStyle get titleMedium => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.4,
        letterSpacing: 0,
      );

  // ── Cuerpo — Manrope Regular ─────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 24 / 16, // line-height 24 del Figma
        letterSpacing: 0,
      );

  static TextStyle get bodyMedium => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
        letterSpacing: 0,
      );

  static TextStyle get bodySmall => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.5,
        letterSpacing: 0,
      );

  // ── Labels / Botones — Manrope SemiBold ─────────────
  static TextStyle get labelLarge => GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.4,
        letterSpacing: 0,
      );

  static TextStyle get labelMedium => GoogleFonts.manrope(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        height: 1.4,
        letterSpacing: 0,
      );

  static TextStyle get labelSmall => GoogleFonts.manrope(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        height: 1.4,
        letterSpacing: 0,
      );

  static TextStyle get caption => GoogleFonts.manrope(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textHint,
        height: 1.4,
        letterSpacing: 0,
      );
}
