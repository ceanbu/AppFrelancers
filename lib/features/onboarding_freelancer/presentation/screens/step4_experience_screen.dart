import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

class Step4ExperienceScreen extends StatefulWidget {
  const Step4ExperienceScreen({super.key});

  @override
  State<Step4ExperienceScreen> createState() => _Step4ExperienceScreenState();
}

class _Step4ExperienceScreenState extends State<Step4ExperienceScreen> {
  final List<Map<String, dynamic>> _experiences = [];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // Retroceso bloqueado intencionalmente durante el onboarding
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paso 4 - Experiencia Laboral'),
        ),
        body: Column(
          children: [
            Expanded(
              child: _experiences.isEmpty
                  ? const Center(child: Text('No has agregado experiencia laboral aún'))
                  : ListView.builder(
                      itemCount: _experiences.length,
                      itemBuilder: (context, index) {
                        final exp = _experiences[index];
                        final start = exp['startDate'];
                        final end = exp['isCurrent'] ? 'Actual' : (exp['endDate'] ?? '');
                        final subtitle = '${exp['company']} · $start - $end';
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          child: ListTile(
                            title: Text(exp['position']),
                            subtitle: Text(subtitle),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editExperience(index),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => setState(() => _experiences.removeAt(index)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _addExperience,
                icon: const Icon(Icons.add),
                label: const Text('Agregar experiencia'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Guardar y Finalizar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addExperience() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExperienceForm()),
    );
    if (result != null) {
      setState(() => _experiences.add(result));
    }
  }

  Future<void> _editExperience(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExperienceForm(initialData: _experiences[index])),
    );
    if (result != null) {
      setState(() => _experiences[index] = result);
    }
  }

  Future<void> _saveAndContinue() async {
    setState(() => _isLoading = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('freelancers').doc(uid).update({
        'experience': _experiences.map((e) => {
          'company': e['company'],
          'position': e['position'],
          'startDate': e['startDate'],
          'endDate': e['isCurrent'] ? null : e['endDate'],
          'isCurrent': e['isCurrent'],
          'description': e['description'] ?? '',
        }).toList(),
      });
      if (mounted) {
        context.go('/freelancer/jobs');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }
}

class ExperienceForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  const ExperienceForm({super.key, this.initialData});

  @override
  State<ExperienceForm> createState() => _ExperienceFormState();
}

class _ExperienceFormState extends State<ExperienceForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _companyController;
  late TextEditingController _positionController;
  late TextEditingController _startDateController;
  late TextEditingController _endDateController;
  late TextEditingController _descriptionController;
  late bool _isCurrent;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _companyController = TextEditingController(text: data?['company'] ?? '');
    _positionController = TextEditingController(text: data?['position'] ?? '');
    _startDateController = TextEditingController(text: data?['startDate'] ?? '');
    _endDateController = TextEditingController(text: data?['endDate'] ?? '');
    _descriptionController = TextEditingController(text: data?['description'] ?? '');
    _isCurrent = data?['isCurrent'] ?? false;
    if (data != null && data['startDate'] != null) {
      _startDate = _parseDate(data['startDate']);
    }
    if (data != null && data['endDate'] != null && !_isCurrent) {
      _endDate = _parseDate(data['endDate']);
    }
  }

  DateTime? _parseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialData == null ? 'Nueva experiencia' : 'Editar experiencia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(labelText: 'Empresa *'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _positionController,
                decoration: const InputDecoration(labelText: 'Cargo *'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _startDateController,
                decoration: const InputDecoration(labelText: 'Fecha inicio (YYYY-MM) *', hintText: '2023-01'),
                validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) {
                    _startDate = date;
                    _startDateController.text = DateFormat('yyyy-MM').format(date);
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _isCurrent,
                    onChanged: (v) => setState(() => _isCurrent = v ?? false),
                  ),
                  const Text('Trabajo actual'),
                ],
              ),
              if (!_isCurrent) ...[
                TextFormField(
                  controller: _endDateController,
                  decoration: const InputDecoration(labelText: 'Fecha fin (YYYY-MM) *', hintText: '2024-12'),
                  validator: (v) => _isCurrent ? null : (v == null || v.isEmpty ? 'Requerido' : null),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      _endDate = date;
                      _endDateController.text = DateFormat('yyyy-MM').format(date);
                    }
                  },
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'company': _companyController.text,
        'position': _positionController.text,
        'startDate': _startDateController.text,
        'endDate': _isCurrent ? null : _endDateController.text,
        'isCurrent': _isCurrent,
        'description': _descriptionController.text,
      };
      Navigator.pop(context, data);
    }
  }
}