import 'package:flutter/material.dart';

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  TimeRange({required this.start, required this.end}) {
    if (start.hour == end.hour && start.minute == end.minute) {
      throw ArgumentError('La hora de inicio y fin no pueden ser iguales');
    }
  }

  Map<String, dynamic> toMap() => {
    'start': '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
    'end': '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}',
  };

  factory TimeRange.fromMap(Map<String, dynamic> map) {
    final range = tryFromMap(map);
    if (range == null) throw FormatException('Formato de horario inválido: $map');
    return range;
  }

  Map<String, String> toJson() => {
    'start': '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
    'end': '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}',
  };

  // Retorna null si no se puede parsear, en lugar de lanzar excepción
  static TimeRange? tryFromJson(Map<String, dynamic> json) => tryFromMap(json);

  static TimeRange? tryFromMap(Map<String, dynamic> json) {
    try {
      final startStr = json['start'] as String;
      final endStr = json['end'] as String;
      final startParts = startStr.split(':');
      final endParts = endStr.split(':');
      if (startParts.length != 2 || endParts.length != 2) return null;
      final startHour = int.tryParse(startParts[0]);
      final startMinute = int.tryParse(startParts[1]);
      final endHour = int.tryParse(endParts[0]);
      final endMinute = int.tryParse(endParts[1]);
      if (startHour == null || startMinute == null || endHour == null || endMinute == null) return null;
      return TimeRange(
        start: TimeOfDay(hour: startHour, minute: startMinute),
        end: TimeOfDay(hour: endHour, minute: endMinute),
      );
    } catch (e) {
      return null;
    }
  }

  // Mantenemos fromJson para compatibilidad, pero ahora llama a tryFromMap y lanza si es null
  factory TimeRange.fromJson(Map<String, dynamic> json) {
    final range = tryFromMap(json);
    if (range == null) throw FormatException('Formato de horario inválido: $json');
    return range;
  }

  String format(BuildContext context) => '${start.format(context)} - ${end.format(context)}';
}
