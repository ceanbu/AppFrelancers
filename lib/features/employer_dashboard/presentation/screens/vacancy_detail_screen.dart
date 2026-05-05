import 'package:flutter/material.dart';

class VacancyDetailScreen extends StatelessWidget {
  final String vacancyId;
  const VacancyDetailScreen({super.key, required this.vacancyId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de vacante')),
      body: Center(
        child: Text('Vacante ID:  - Detalle (en construcción)'),
      ),
    );
  }
}
