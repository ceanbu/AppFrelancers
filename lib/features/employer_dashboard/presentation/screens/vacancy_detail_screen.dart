import 'package:flutter/material.dart';

// TODO: Implementar VacancyDetailScreen
class VacancyDetailScreen extends StatelessWidget {
  final String vacancyId;
  const VacancyDetailScreen({super.key, required this.vacancyId});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de Vacante')),
      body: Center(child: Text('vacancyId: $vacancyId')),
    );
  }
}
