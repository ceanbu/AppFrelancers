import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:workflex/core/widgets/wf_calendar.dart';
import 'package:workflex/core/models/time_range.dart';
class CreateVacancyStep1Screen extends StatefulWidget {
  const CreateVacancyStep1Screen({super.key});
  @override
  State<CreateVacancyStep1Screen> createState() => _CreateVacancyStep1ScreenState();
}
class _CreateVacancyStep1ScreenState extends State<CreateVacancyStep1Screen> {
  Map<String, List<TimeRange>> _schedule = {};
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Crear vacante - Fechas y horarios'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: WFCalendar(
              initialAvailability: _schedule,
              onChanged: (newSchedule) => setState(() => _schedule = newSchedule),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                final hasAnyRange = _schedule.values.any((ranges) => ranges.isNotEmpty);
                if (_schedule.isEmpty || !hasAnyRange) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Selecciona al menos un dia y horarios')),
                  );
                  return;
                }
                context.push('/employer/vacancy/create/step2', extra: _schedule);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: const Text('Continuar'),
            ),
          ),
        ],
      ),
    );
  }
}