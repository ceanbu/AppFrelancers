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
    'start': ':',
    'end': ':',
  };

  factory TimeRange.fromJson(Map<String, dynamic> json) {
    final startParts = json['start'].split(':');
    final endParts = json['end'].split(':');
    return TimeRange(
      start: TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1])),
      end: TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1])),
    );
  }

  String format(BuildContext context) => ' - ';
}
