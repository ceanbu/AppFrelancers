import 'package:flutter/material.dart';

class CreateVacancyStep1Screen extends StatelessWidget {
  const CreateVacancyStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear vacante - Fechas y horarios')),
      body: const Center(
        child: Text('Aquí irá el calendario (WFCalendar) - en construcción'),
      ),
    );
  }
}
