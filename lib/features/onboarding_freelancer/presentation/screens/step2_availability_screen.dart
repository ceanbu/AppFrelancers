import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/models/time_range.dart';

class Step2AvailabilityScreen extends StatefulWidget {
  const Step2AvailabilityScreen({super.key});

  @override
  State<Step2AvailabilityScreen> createState() => _Step2AvailabilityScreenState();
}

class _Step2AvailabilityScreenState extends State<Step2AvailabilityScreen> {
  late Map<String, List<TimeRange>> _availability;
  late Set<DateTime> _selectedDays;
  late DateTime _focusedDay;
  late CalendarFormat _calendarFormat;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _availability = {};
    _selectedDays = {};
    _focusedDay = DateTime.now();
    _calendarFormat = CalendarFormat.month;
    _loadExistingAvailability();
  }

  Future<void> _loadExistingAvailability() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('freelancers').doc(uid).get();
    final data = doc.data();
    if (data != null && data.containsKey('availability')) {
      final Map<String, dynamic> availabilityMap = data['availability'];
      setState(() {
        for (var entry in availabilityMap.entries) {
          final date = DateTime.tryParse(entry.key);
          if (date != null) {
            _selectedDays.add(date);
            final ranges = (entry.value as List).map((r) {
              // Usar tryFromJson para evitar errores
              final range = TimeRange.tryFromJson(r);
              if (range == null) {
                print('Rango inválido ignorado: $r');
                return null;
              }
              return range;
            }).where((r) => r != null).cast<TimeRange>().toList();
            if (ranges.isNotEmpty) {
              _availability[entry.key] = ranges;
            }
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paso 2 - Disponibilidad'),
        ),
        body: Column(
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
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAvailability,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: _isSaving
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar y continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDaysList() {
    if (_selectedDays.isEmpty) {
      return const Center(child: Text('Toca en un día del calendario para seleccionarlo'));
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
                    Text(DateFormat('EEEE, d MMMM yyyy', 'es_ES').format(day),
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => setState(() {
                        _selectedDays.remove(day);
                        _availability.remove(dayKey);
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
      builder: (_) => const TimeRangeDialog(),
    );
    if (range != null) {
      setState(() {
        final key = DateFormat('yyyy-MM-dd').format(day);
        _availability.putIfAbsent(key, () => []).add(range);
      });
    }
  }

  Future<void> _editTimeRange(DateTime day, int index) async {
    final key = DateFormat('yyyy-MM-dd').format(day);
    final oldRange = _availability[key]![index];
    final newRange = await showDialog<TimeRange>(
      context: context,
      builder: (_) => TimeRangeDialog(initialStart: oldRange.start, initialEnd: oldRange.end),
    );
    if (newRange != null) {
      setState(() {
        _availability[key]![index] = newRange;
      });
    }
  }

  Future<void> _saveAvailability() async {
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      // Convertir correctamente cada TimeRange a Map
      final availabilityMap = _availability.map((key, ranges) => MapEntry(key, ranges.map((r) => r.toJson()).toList()));
      await FirebaseFirestore.instance.collection('freelancers').doc(uid).update({
        'availability': availabilityMap,
      });
      if (mounted) {
        context.go('/freelancer/register/step3');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isSaving = false);
    }
  }
}

class TimeRangeDialog extends StatefulWidget {
  final TimeOfDay? initialStart;
  final TimeOfDay? initialEnd;
  const TimeRangeDialog({super.key, this.initialStart, this.initialEnd});

  @override
  State<TimeRangeDialog> createState() => _TimeRangeDialogState();
}

class _TimeRangeDialogState extends State<TimeRangeDialog> {
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
