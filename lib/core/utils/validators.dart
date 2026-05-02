/// Validadores de reglas de negocio de WorkFlex
class AppValidators {
  AppValidators._();

  /// RF1.2 / RF1.5 — El usuario debe tener 18 años o más
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

  /// RF1.3.3 / RF2.2.A.5 — La hora de inicio debe ser anterior a la de fin
  /// Permite turnos que crucen medianoche (ej: 22:00 → 02:00)
  static String? validateTimeRange(TimeOfDay start, TimeOfDay end) {
    // Si start > end asumimos que cruza medianoche: válido
    // Si son iguales: inválido
    if (start.hour == end.hour && start.minute == end.minute) {
      return 'La hora de inicio no puede ser igual a la de fin';
    }
    return null;
  }

  /// Contraseña mínimo 6 caracteres (RF1.2)
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'La contraseña es requerida';
    if (value.length < 6) return 'La contraseña debe tener al menos 6 caracteres';
    return null;
  }

  /// Confirmación de contraseña
  static String? validatePasswordConfirm(String? value, String password) {
    if (value == null || value.isEmpty) return 'Confirmá tu contraseña';
    if (value != password) return 'Las contraseñas no coinciden';
    return null;
  }

  /// Email básico
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'El email es requerido';
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) return 'Ingresá un email válido';
    return null;
  }

  /// Campo requerido genérico
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Este campo'} es requerido';
    }
    return null;
  }

  /// Teléfono con DDD (Brasil: 10-11 dígitos)
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) return 'El teléfono es requerido';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 10 || digits.length > 11) {
      return 'Ingresá un teléfono válido con DDD (ej: 11 99999-9999)';
    }
    return null;
  }

  /// CPF — 11 dígitos
  static String? validateCPF(String? value) {
    if (value == null || value.isEmpty) return 'El CPF es requerido';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) return 'CPF inválido';
    return null;
  }
}
