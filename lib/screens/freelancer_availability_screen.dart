import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart' as tc; // Usando el prefijo tc

// Definición local de TimeSlot y TimeSlotDialog
class TimeSlot {
  final TimeOfDay startTime;
  final TimeOfDay endTime;

  TimeSlot({required this.startTime, required this.endTime});

  @override
  String toString() {
    final startHour = startTime.hour.toString().padLeft(2, '0');
    final startMinute = startTime.minute.toString().padLeft(2, '0');
    final endHour = endTime.hour.toString().padLeft(2, '0');
    final endMinute = endTime.minute.toString().padLeft(2, '0');
    return '$startHour:$startMinute - $endHour:$endMinute';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TimeSlot &&
          runtimeType == other.runtimeType &&
          startTime == other.startTime &&
          endTime == other.endTime;

  @override
  int get hashCode => startTime.hashCode ^ endTime.hashCode;
}

class TimeSlotDialog extends StatefulWidget {
  final TimeOfDay? initialStartTime;
  final TimeOfDay? initialEndTime;

  const TimeSlotDialog({
    super.key,
    this.initialStartTime,
    this.initialEndTime,
  });

  @override
  State<TimeSlotDialog> createState() => _TimeSlotDialogState();
}

class _TimeSlotDialogState extends State<TimeSlotDialog> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = widget.initialStartTime ?? const TimeOfDay(hour: 9, minute: 0);
    _endTime = widget.initialEndTime ?? const TimeOfDay(hour: 17, minute: 0);
  }

  Future<TimeOfDay?> _showCustomTimePicker(
      BuildContext context, TimeOfDay initialTime) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child ?? Container(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return AlertDialog(
      title: Text('Configurar Horário', style: textTheme.titleLarge),
      contentPadding: const EdgeInsets.all(20.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text('Hora de Início', style: textTheme.bodyLarge),
            trailing: Text(_startTime.format(context), style: textTheme.bodyLarge?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
            onTap: () async {
              final time = await _showCustomTimePicker(context, _startTime);
              if (time != null) {
                setState(() => _startTime = time);
              }
            },
          ),
          const SizedBox(height: 10),
          ListTile(
            title: Text('Hora de Fim', style: textTheme.bodyLarge),
            trailing: Text(_endTime.format(context), style: textTheme.bodyLarge?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
            onTap: () async {
              final time = await _showCustomTimePicker(context, _endTime);
              if (time != null) {
                setState(() => _endTime = time);
              }
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'), // Estilo vendrá del TextButtonTheme
        ),
        ElevatedButton( // Usar ElevatedButton para el botón principal del diálogo
          onPressed: () {
            if (_startTime.hour > _endTime.hour ||
                (_startTime.hour == _endTime.hour &&
                    _startTime.minute >= _endTime.minute)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('A hora de início deve ser anterior à hora de fim.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
              return;
            }
            Navigator.pop(context, TimeSlot(startTime: _startTime, endTime: _endTime));
          },
          // El estilo vendrá del ElevatedButtonTheme, pero podemos forzar el color específico si es necesario
           style: ElevatedButton.styleFrom(
             backgroundColor: const Color(0xFF0A78ED),
             foregroundColor: Colors.white,
           ),
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}


class FreelancerAvailabilityScreen extends StatefulWidget {
  const FreelancerAvailabilityScreen({super.key});

  @override
  State<FreelancerAvailabilityScreen> createState() =>
      _FreelancerAvailabilityScreenState();
}

class _FreelancerAvailabilityScreenState
    extends State<FreelancerAvailabilityScreen> {
  Map<DateTime, List<TimeSlot>> _availability = {};
  DateTime _focusedMonth = DateTime.now();
  Set<DateTime> _selectedDates = {};
  tc.CalendarFormat _calendarFormat = tc.CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.utc(_focusedMonth.year, _focusedMonth.month, 1);
    // Inicializa el formato de fecha para el locale deseado
    // Asegúrate que el locale que uses aquí ('es_ES', 'pt_BR', etc.)
    // esté en supportedLocales en main.dart y que initializeDateFormatting se llame.
    final currentLocale = Localizations.localeOf(context).toString();
    initializeDateFormatting(currentLocale.isEmpty ? 'es_ES' : currentLocale , null).then((_) {
      if (mounted) {
        setState(() {});
      }
    }).catchError((error) {
        print("Error inicializando formato de fecha: $error");
        // Fallback a un locale por defecto si falla la carga del locale del sistema
        initializeDateFormatting('es_ES', null).then((_) { // O 'en_US'
            if (mounted) setState(() {});
        });
    });
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day);
  }

  Future<void> _addOrEditTimeSlot(BuildContext context, DateTime date, [TimeSlot? existingSlot]) async {
    final newSlot = await showDialog<TimeSlot>(
      context: context,
      builder: (context) {
        return TimeSlotDialog(
          initialStartTime: existingSlot?.startTime,
          initialEndTime: existingSlot?.endTime,
        );
      },
    );

    if (newSlot != null) {
      setState(() {
        final normalizedDate = _normalizeDate(date);
        _availability.putIfAbsent(normalizedDate, () => []);

        // Si es una edición, removemos el slot existente antes de añadir el nuevo/modificado
        if (existingSlot != null) {
          _availability[normalizedDate]?.removeWhere((slot) =>
            slot.startTime == existingSlot.startTime && slot.endTime == existingSlot.endTime);
        }
        _availability[normalizedDate]?.add(newSlot);
        // Ordenar slots por hora de inicio
        _availability[normalizedDate]?.sort((a, b) {
          final startTimeA = a.startTime.hour * 60 + a.startTime.minute;
          final startTimeB = b.startTime.hour * 60 + b.startTime.minute;
          return startTimeA.compareTo(startTimeB);
        });
      });
    }
  }

  void _saveAvailability() {
    print('Disponibilidade a ser salva:');
     _availability.forEach((date, slots) {
      print('Data: ${DateFormat.yMd(Localizations.localeOf(context).toString()).format(date)}, Horários: ${slots.join(" | ")}');
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Disponibilidade salva com sucesso (simulação)!')),
    );
    // Navigator.pop(context); // Opcional, para volver
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final String currentLocale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Disponibilidade'),
        // El estilo del AppBar ya viene del ThemeData
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0), // Aumentado el padding general
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecione os dias no calendário:',
              style: textTheme.titleLarge?.copyWith(color: colorScheme.onBackground), // Usando un estilo de título del tema
            ),
            const SizedBox(height: 12),
            Card( // Envolver el TableCalendar en una Card para aplicar sombra y bordes redondeados del tema
              elevation: Theme.of(context).cardTheme.elevation ?? 2, // Usa elevación del tema o default
              shape: Theme.of(context).cardTheme.shape, // Usa forma del tema
              child: Padding(
                padding: const EdgeInsets.all(8.0), // Padding interno para la Card
                child: tc.TableCalendar(
                  locale: currentLocale.isNotEmpty ? currentLocale : 'es_ES', // Usa el locale del contexto o fallback
                  firstDay: DateTime.utc(_focusedMonth.year, _focusedMonth.month, 1), // Primer día del mes enfocado
                  lastDay: DateTime.utc(_focusedMonth.year + 1, _focusedMonth.month, 0), // Un año hacia adelante
                  focusedDay: _focusedMonth,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) {
                    return _selectedDates.contains(_normalizeDate(day));
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      DateTime normalizedSelectedDay = _normalizeDate(selectedDay);
                      if (_selectedDates.contains(normalizedSelectedDay)) {
                         // Al tocar un día ya seleccionado, no lo removemos de _selectedDates
                         // para permitir al usuario añadir múltiples rangos o simplemente ver/editar.
                         // La eliminación de un día de la selección se hará desde la lista de abajo.
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
                  calendarBuilders: tc.CalendarBuilders(
                    selectedBuilder: (context, date, focusedDay) => Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorScheme.primary, // Color primario del tema
                        shape: BoxShape.circle,
                      ),
                      child: Text(date.day.toString(), style: const TextStyle(color: Colors.white)),
                    ),
                    todayBuilder: (context, date, focusedDay) => Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withOpacity(0.5), // Color secundario del tema
                        shape: BoxShape.circle,
                      ),
                      child: Text(date.day.toString(), style: TextStyle(color: colorScheme.onSecondary)),
                    ),
                  ),
                  headerStyle: tc.HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false, // Mantenemos el formato de mes
                    titleTextStyle: textTheme.titleMedium ?? const TextStyle(fontSize: 17.0),
                    leftChevronIcon: Icon(Icons.chevron_left, color: colorScheme.onSurface),
                    rightChevronIcon: Icon(Icons.chevron_right, color: colorScheme.onSurface),
                  ),
                  daysOfWeekStyle: tc.DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.7)),
                    weekendStyle: TextStyle(color: colorScheme.primary.withOpacity(0.8)),
                  ),
                  calendarStyle: tc.CalendarStyle(
                     defaultTextStyle: TextStyle(color: colorScheme.onSurface),
                     weekendTextStyle: TextStyle(color: colorScheme.primary),
                     outsideTextStyle: TextStyle(color: colorScheme.onSurface.withOpacity(0.4)),
                  )
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 20),
            Text(
              'Horários para Datas Selecionadas:',
              style: textTheme.titleLarge?.copyWith(color: colorScheme.onBackground),
            ),
            const SizedBox(height: 10),
            _selectedDates.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Nenhuma data selecionada.\nToque em um dia no calendário para configurar horários.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.7)),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _selectedDates.length,
                    itemBuilder: (context, index) {
                      List<DateTime> sortedDates = _selectedDates.toList()..sort((a, b) => a.compareTo(b));
                      DateTime date = sortedDates[index];
                      List<TimeSlot> slotsForDate = _availability[_normalizeDate(date)] ?? [];

                      return Card( // Card ya toma estilo del CardTheme
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    DateFormat('EEEE, d \'de\' MMMM', currentLocale.isNotEmpty ? currentLocale : 'es_ES').format(date),
                                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, color: Colors.grey.shade600),
                                    tooltip: 'Remover este dia da seleção',
                                    onPressed: () {
                                      setState(() {
                                        _selectedDates.remove(date);
                                        _availability.remove(date);
                                      });
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (slotsForDate.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text('Nenhum horário definido para este dia.', style: textTheme.bodyMedium),
                                ),
                              ...slotsForDate.map((slot) {
                                return ListTile(
                                  title: Text(slot.toString(), style: textTheme.bodyLarge),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                    onPressed: () {
                                      setState(() {
                                        _availability[date]?.remove(slot);
                                        if (_availability[date]?.isEmpty ?? false) {
                                           // Opcional: si se borran todos los slots, ¿deseleccionar el día?
                                           // _selectedDates.remove(date);
                                        }
                                      });
                                    },
                                  ),
                                  onTap: () {
                                    _addOrEditTimeSlot(context, date, slot);
                                  },
                                );
                              }).toList(),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  icon: const Icon(Icons.add_alarm),
                                  label: const Text('Adicionar Horário'),
                                  // Estilo del TextButton viene del tema
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
                icon: const Icon(Icons.save_alt_outlined),
                label: const Text('Salvar Disponibilidade'),
                onPressed: _saveAvailability,
                style: ElevatedButton.styleFrom( // Asegurando el color específico
                  backgroundColor: const Color(0xFF0A78ED),
                  foregroundColor: Colors.white,
                  // El padding y textStyle general vienen del tema
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

**Cambios Clave en este código:**

1.  **Clases `TimeSlot` y `TimeSlotDialog` movidas al inicio del archivo:** Para mejor organización, ya que son específicas de esta pantalla en tu implementación actual.
2.  **Importación `time_slot.dart` eliminada:** Ya no es necesaria porque las clases están definidas localmente.
3.  **Localización en `initState`:** Mejorada la lógica para usar `Localizations.localeOf(context)` y tener un fallback. Asegúrate de que los locales que uses ('es\_ES', 'pt\_BR') estén en `supportedLocales` en tu `main.dart`.
4.  **`TableCalendar` envuelto en `Card`:** Para que tome el estilo (sombra, bordes redondeados) definido en `cardTheme` en `main.dart`.
5.  **Estilos de Texto:** Se usan más consistentemente los estilos de `textTheme` (ej. `textTheme.titleLarge`, `textTheme.titleMedium`, `textTheme.bodyMedium`).
6.  **Estilos de `TableCalendar`:** Se usan colores del `colorScheme` del tema para los días seleccionados y el día actual, y para los chevrons de navegación de mes.
7.  **Botón "Salvar Disponibilidade":** Se asegura que use el color `0xFF0A78ED` y se le añadió un icono.
8.  **Pequeños ajustes de padding y espaciado.**
9.  **Lógica de `onDaySelected` en `TableCalendar`:** Modifiqué ligeramente para que al tocar un día ya seleccionado *no* se deseleccione inmediatamente del calendario. Esto permite al usuario ver el día marcado y luego decidir si quiere añadir horarios o quitarlo desde la lista de abajo. Si prefieres el comportamiento anterior (que se deseleccione al tocarlo de nuevo en el calendario), puedes revertir esa parte.
10. **Edición de `TimeSlot`:** En `_addOrEditTimeSlot`, al editar un slot, ahora se busca y elimina el slot existente de forma más precisa antes de añadir el modificado, para evitar duplicados si la hora de inicio/fin cambia.

**Después de reemplazar y guardar `lib/screens/freelancer_availability_screen.dart`:**

*   **Reinicia completamente tu aplicación.**
*   Navega a la pantalla de Configurar Disponibilidad.

Observa la apariencia general. El calendario debería estar dentro de una tarjeta, los textos deberían usar la fuente y los colores del tema, y el botón "Salvar Disponibilidade" debería tener el estilo y color correctos.

Avísame cómo se ve y si esta versión se acerca más a lo que esperas.
