import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart' as tc; // Usando el prefijo tc
import 'package:jobbit/models/time_slot.dart';

class FreelancerAvailabilityScreen extends StatefulWidget {
  const FreelancerAvailabilityScreen({super.key});

  @override
  State<FreelancerAvailabilityScreen> createState() => _FreelancerAvailabilityScreenState();
}

class _FreelancerAvailabilityScreenState extends State<FreelancerAvailabilityScreen> {
  Map<DateTime, List<TimeSlot>> _availability = {};
  DateTime _focusedMonth = DateTime.now();
  Set<DateTime> _selectedDates = {};
  tc.CalendarFormat _calendarFormat = tc.CalendarFormat.month; // Usando tc.

  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.utc(_focusedMonth.year, _focusedMonth.month, 1);
  }

  // Función para mostrar el TimePicker y añadir/editar TimeSlots
  Future<void> _addOrEditTimeSlot(BuildContext context, DateTime date, [TimeSlot? existingSlot]) async {
    TimeOfDay? startTime = existingSlot?.startTime ?? const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay? endTime = existingSlot?.endTime ?? const TimeOfDay(hour: 17, minute: 0);

    // Show Start Time Picker
    final TimeOfDay? pickedStartTime = await showTimePicker(
      context: context,
      initialTime: startTime,
      helpText: 'Selecione o Horário de Início',
    );

    if (pickedStartTime != null) {
      startTime = pickedStartTime;

      // Show End Time Picker
      final TimeOfDay? pickedEndTime = await showTimePicker(
        context: context,
        initialTime: endTime, // Sugerir una hora después del inicio o la hora final existente
        helpText: 'Selecione o Horário de Término',
      );

      if (pickedEndTime != null) {
        endTime = pickedEndTime;

        // Validación simple: hora final después de hora inicial
        if ((endTime.hour < startTime.hour) || (endTime.hour == startTime.hour && endTime.minute <= startTime.minute)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('O horário de término deve ser posterior ao horário de início.')),
            );
          }
          return;
        }

        setState(() {
          final normalizedDate = _normalizeDate(date);
          _availability.putIfAbsent(normalizedDate, () => []); // Asegura que la lista exista

          if (existingSlot != null) { // Editando
            int slotIndex = _availability[normalizedDate]!.indexOf(existingSlot);
            if (slotIndex != -1) {
               _availability[normalizedDate]![slotIndex] = TimeSlot(startTime: startTime!, endTime: endTime!);
            }
          } else { // Añadiendo nuevo
            _availability[normalizedDate]!.add(TimeSlot(startTime: startTime!, endTime: endTime!));
          }
          // Opcional: ordenar slots por hora de inicio
          _availability[normalizedDate]!.sort((a, b) {
            final сравнениеЧасов = a.startTime.hour.compareTo(b.startTime.hour);
            if (сравнениеЧасов != 0) return сравнениеЧасов;
            return a.startTime.minute.compareTo(b.startTime.minute);
          });
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Disponibilidade'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecione os dias no calendário:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            tc.TableCalendar( // Usando tc.
              locale: 'pt_BR',
              firstDay: DateTime.utc(_focusedMonth.year - 1, _focusedMonth.month, 1),
              lastDay: DateTime.utc(_focusedMonth.year + 1, _focusedMonth.month + 1, 0),
              focusedDay: _focusedMonth,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return _selectedDates.contains(_normalizeDate(day));
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  DateTime normalizedSelectedDay = _normalizeDate(selectedDay);
                  if (_selectedDates.contains(normalizedSelectedDay)) {
                    // No se deselecciona al tocar de nuevo, se mantiene para editar horarios
                    // Si quieres deseleccionar, descomenta la siguiente línea:
                    // _selectedDates.remove(normalizedSelectedDay);
                  } else {
                    _selectedDates.add(normalizedSelectedDay);
                  }
                  _focusedMonth = _normalizeDate(focusedDay);
                });
              },
              onPageChanged: (focusedDay) {
                setState(() {
                  _focusedMonth = _normalizeDate(focusedDay);
                });
              },
              calendarBuilders: tc.CalendarBuilders( // Usando tc.
                selectedBuilder: (context, date, events) => Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.7), // Un poco más claro si está seleccionado
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    date.day.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                todayBuilder: (context, date, events) => Container(
                  margin: const EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.3), // Diferente color para hoy
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    date.day.toString(),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
              ),
              headerStyle: const tc.HeaderStyle( // Usando tc.
                titleCentered: true,
                formatButtonVisible: false,
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            const Text(
              'Definir Horários para Datas Selecionadas:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _selectedDates.isEmpty
                ? const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.0),
                    child: Text('Nenhuma data selecionada. Toque em um dia no calendário para configurar horários.'),
                  ))
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _selectedDates.length,
                    itemBuilder: (context, index) {
                      List<DateTime> sortedDates = _selectedDates.toList()..sort((a, b) => a.compareTo(b));
                      DateTime date = sortedDates[index];
                      List<TimeSlot> slotsForDate = _availability[date] ?? [];

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Dia: ${date.day}/${date.month}/${date.year}',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.close, color: Colors.grey),
                                    tooltip: 'Remover seleção deste dia',
                                    onPressed: () {
                                      setState(() {
                                        _selectedDates.remove(date);
                                        _availability.remove(date); // También remueve los horarios asociados
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (slotsForDate.isEmpty)
                                const Text('Nenhum horário definido para este dia.'),
                              ...slotsForDate.map((slot) {
                                return ListTile(
                                  title: Text(slot.toString()),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () {
                                      setState(() {
                                        _availability[date]?.remove(slot);
                                        if (_availability[date]?.isEmpty ?? false) {
                                          // Opcional: si no quedan slots, podríamos también deseleccionar el día
                                          // _selectedDates.remove(date);
                                        }
                                      });
                                    },
                                  ),
                                  onTap: () { // Para editar
                                     _addOrEditTimeSlot(context, date, slot);
                                  }
                                );
                              }).toList(),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  icon: const Icon(Icons.add_alarm),
                                  label: const Text('Adicionar Horário'),
                                  onPressed: () {
                                    _addOrEditTimeSlot(context, date);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Salvar Disponibilidade'),
                onPressed: () {
                  print('Disponibilidade a ser salva:');
                  _availability.forEach((date, slots) {
                    print('Data: ${date.toIso8601String().substring(0,10)}, Horários: ${slots.join(", ")}');
                  });
                  print('Datas selecionadas (apenas para UI): $_selectedDates');

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configuração de disponibilidade (simulação) salva!')),
                  );
                  // Navigator.pop(context); // Descomentar para volver a la pantalla anterior
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0A78ED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

```
**Cambios importantes en este código:**

1.  **Prefijo `tc` añadido:** `import 'package:table_calendar/table_calendar.dart' as tc;` y se usa `tc.TableCalendar`, `tc.CalendarFormat`, `tc.CalendarBuilders`, `tc.HeaderStyle`.
2.  **Lógica para añadir y mostrar `TimeSlot`s (Básica):**
    *   He añadido una función `_addOrEditTimeSlot` que usa `showTimePicker` para seleccionar hora de inicio y fin.
    *   Las fechas seleccionadas ahora muestran un botón "Adicionar Horário".
    *   Los horarios añadidos se muestran y tienen un botón para eliminarlos.
    *   Se puede tocar un horario existente para editarlo (vuelve a abrir los `TimePicker`).
3.  **Mejoras en la UI:**
    *   Las fechas seleccionadas se listan en `Card`s.
    *   Botón para deseleccionar un día de la lista de "Horários para Datas Selecionadas".
    *   El botón "Salvar Disponibilidade" ahora tiene un icono.
    *   Pequeños ajustes en el `TableCalendar` para la apariencia de días seleccionados y el día de hoy.
    *   Se normaliza la fecha en `_focusedMonth` para evitar problemas de comparación.
    *   Se corrigió `lastDay` en `TableCalendar` para calcular correctamente el último día del mes siguiente.

Por favor, reemplaza el contenido de `lib/screens/freelancer_availability_screen.dart` con este nuevo código, guarda y prueba de nuevo. Espero que esto resuelva el problema de los argumentos y te permita avanzar. ¡Avísame el resultado!
