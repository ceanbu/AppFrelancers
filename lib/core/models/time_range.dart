import 'package:flutter/material.dart';

class TimeRange {
  final TimeOfDay start;
  final TimeOfDay end;

  TimeRange({required this.start, required this.end}) {
    if (start.hour == end.hour && start.minute == end.minute) {
      throw ArgumentError('La hora de inicio y fin no pueden ser iguales');
    }
  }

  Map<String, String> toJson() => {
    'start': '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}',
    'end': '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}',
  };

  Map<String, String> toMap() => toJson();

  static TimeRange? tryFromJson(Map<String, dynamic> json) {
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

  static TimeRange fromMap(Map<String, dynamic> map) {
    final range = tryFromJson(map);
    if (range == null) throw FormatException('Formato de horario inválido: $map');
    return range;
  }

  factory TimeRange.fromJson(Map<String, dynamic> json) => fromMap(json);

  String format(BuildContext context) => '${start.format(context)} - ${end.format(context)}';
}
