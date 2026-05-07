import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:workflex/core/models/time_range.dart';

/// Widget reutilizable para selección de fechas y rangos horarios.
/// Proporciona un calendario y una lista de días seleccionados con sus horarios.
/// Recibe:
///   - initialAvailability: mapa de fechas a lista de rangos.
///   - onChanged: callback que devuelve el mapa actualizado cuando el usuario modifica algo.
class WFCalendar extends StatefulWidget {
  final Map<String, List<TimeRange>> initialAvailability;
  final Function(Map<String, List<TimeRange>>) onChanged;

  const WFCalendar({
    super.key,
    this.initialAvailability = const {},
    required this.onChanged,
  });

  @override
  State<WFCalendar> createState() => _WFCalendarState();
}

class _WFCalendarState extends State<WFCalendar> {
  late Map<String, List<TimeRange>> _availability;
  late Set<DateTime> _selectedDays;
  late DateTime _focusedDay;
  late CalendarFormat _calendarFormat;

  @override
  void initState() {
    super.initState();
    _availability = Map.from(widget.initialAvailability);
    _selectedDays = {};
    for (var key in _availability.keys) {
      final date = DateTime.tryParse(key);
      if (date != null) _selectedDays.add(date);
    }
    _focusedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
  }

  void _notifyParent() {
    widget.onChanged(_availability);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          firstDay: DateTime.now(),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => _selectedDays.contains(day),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
              final dayKey = DateFormat('yyyy-MM-dd').format(selectedDay);
              if (_selectedDays.contains(selectedDay)) {
                _selectedDays.remove(selectedDay);
                _availability.remove(dayKey);
              } else {
                _selectedDays.add(selectedDay);
                _availability[dayKey] = [];
              }
              _notifyParent();
            });
          },
          onFormatChanged: (format) => setState(() => _calendarFormat = format),
          calendarFormat: _calendarFormat,
          calendarStyle: const CalendarStyle(
            selectedDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
            todayDecoration: BoxDecoration(color: Colors.orange, shape: BoxShape.circle),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _buildSelectedDaysList(),
        ),
      ],
    );
  }

  Widget _buildSelectedDaysList() {
    if (_selectedDays.isEmpty) {
      return const Center(
        child: Text('Toca en un día del calendario para seleccionarlo'),
      );
    }
    final days = _selectedDays.toList()..sort();
    return ListView.builder(
      itemCount: days.length,
      itemBuilder: (context, index) {
        final day = days[index];
        final dayKey = DateFormat('yyyy-MM-dd').format(day);
        final ranges = _availability[dayKey] ?? [];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('EEEE, d MMMM yyyy', 'es_ES').format(day),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => setState(() {
                        _selectedDays.remove(day);
                        _availability.remove(dayKey);
                        _notifyParent();
                      }),
                    ),
                  ],
                ),
                ...ranges.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final range = entry.value;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(child: Text(range.format(context))),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 18),
                          onPressed: () => _editTimeRange(day, idx),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                          onPressed: () => setState(() {
                            ranges.removeAt(idx);
                            if (ranges.isEmpty) _availability.remove(dayKey);
                            _notifyParent();
                          }),
                        ),
                      ],
                    ),
                  );
                }),
                if (ranges.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('Sin horarios definidos', style: TextStyle(color: Colors.grey)),
                  ),
                TextButton.icon(
                  onPressed: () => _addTimeRange(day),
                  icon: const Icon(Icons.add),
                  label: const Text('Añadir horario'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _addTimeRange(DateTime day) async {
    final range = await showDialog<TimeRange>(
      context: context,
      builder: (_) => const _TimeRangeDialog(),
    );
    if (range != null) {
      setState(() {
        final key = DateFormat('yyyy-MM-dd').format(day);
        _availability.putIfAbsent(key, () => []).add(range);
        _notifyParent();
      });
    }
  }

  Future<void> _editTimeRange(DateTime day, int index) async {
    final key = DateFormat('yyyy-MM-dd').format(day);
    final oldRange = _availability[key]![index];
    final newRange = await showDialog<TimeRange>(
      context: context,
      builder: (_) => _TimeRangeDialog(initialStart: oldRange.start, initialEnd: oldRange.end),
    );
    if (newRange != null) {
      setState(() {
        _availability[key]![index] = newRange;
        _notifyParent();
      });
    }
  }
}

class _TimeRangeDialog extends StatefulWidget {
  final TimeOfDay? initialStart;
  final TimeOfDay? initialEnd;
  const _TimeRangeDialog({this.initialStart, this.initialEnd});

  @override
  State<_TimeRangeDialog> createState() => __TimeRangeDialogState();
}

class __TimeRangeDialogState extends State<_TimeRangeDialog> {
  late TimeOfDay _start;
  late TimeOfDay _end;

  @override
  void initState() {
    super.initState();
    _start = widget.initialStart ?? const TimeOfDay(hour: 9, minute: 0);
    _end = widget.initialEnd ?? const TimeOfDay(hour: 18, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Horario'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Hora de inicio'),
            trailing: Text(_start.format(context)),
            onTap: () async {
              final time = await showTimePicker(context: context, initialTime: _start);
              if (time != null) setState(() => _start = time);
            },
          ),
          ListTile(
            title: const Text('Hora de fin'),
            trailing: Text(_end.format(context)),
            onTap: () async {
              final time = await showTimePicker(context: context, initialTime: _end);
              if (time != null) setState(() => _end = time);
            },
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        TextButton(
          onPressed: () {
            try {
              final range = TimeRange(start: _start, end: _end);
              Navigator.pop(context, range);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
            }
          },
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}