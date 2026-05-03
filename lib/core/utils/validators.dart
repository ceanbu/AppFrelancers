import 'package:flutter/material.dart';

class AppValidators {
  AppValidators._();

  static String? validateAge(DateTime? birthDate) {
    if (birthDate == null) return 'La fecha de nacimiento es requerida';
    final today = DateTime.now();
    final age = today.year - birthDate.year;
    final hadBirthdayThisYear = today.month > birthDate.month ||
        (today.month == birthDate.month && today.day >= birthDate.day);
    final realAge = hadBirthdayThisYear ? age : age - 1;
    if (realAge < 18) return 'Debes tener al menos 18 años para registrarte';
    return null;
  }

  static String? validateTimeRange(TimeOfDay start, TimeOfDay end) {
    if (start.hour == end.hour && start.minute == end.minute) {
      return 'La hora de inicio no puede ser igual a la de fin';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es requerida';
    if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
    return null;
  }

  static String? validatePasswordConfirm(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirma tu contraseña';
    if (value != password) return 'Las contraseñas no coinciden';
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'El email es requerido';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return 'Ingresa un email valido';
    return null;
  }

  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? "Este campo"} es requerido';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'El telefono es requerido';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 11) {
      return 'Ingresa un telefono valido con DDD';
    }
    return null;
  }

  static String? validateCPF(String? value) {
    if (value == null || value.isEmpty) return 'El CPF es requerido';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) return 'CPF invalido';
    return null;
  }
}