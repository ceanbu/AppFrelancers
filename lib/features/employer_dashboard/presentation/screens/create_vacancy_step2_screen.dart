import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:workflex/core/widgets/wf_button.dart';
import 'package:workflex/core/widgets/wf_text_field.dart';
import 'package:workflex/core/widgets/wf_skills_selector.dart';
import 'package:workflex/core/models/time_range.dart';
import 'package:workflex/core/constants/app_colors.dart';
import 'package:workflex/core/constants/app_text_styles.dart';
import 'package:workflex/core/widgets/wf_address_ibge.dart';

class CreateVacancyStep2Screen extends StatefulWidget {
  const CreateVacancyStep2Screen({super.key});

  @override
  State<CreateVacancyStep2Screen> createState() => _CreateVacancyStep2ScreenState();
}

class _CreateVacancyStep2ScreenState extends State<CreateVacancyStep2Screen> {
  late Map<String, List<TimeRange>> _schedule;
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _remunerationController = TextEditingController();
  String? _remunerationUnit;
  Map<String, String> _workAddress = {};
  List<String> _requiredSkills = [];
  final _descriptionController = TextEditingController();
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra != null && extra is Map<String, List<TimeRange>>) {
      _schedule = extra;
    } else {
      _schedule = {};
    }
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _remunerationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveVacancy() async {
    if (!_formKey.currentState!.validate()) return;
    if (_requiredSkills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una habilidad requerida')),
      );
      return;
    }
    if (_workAddress['state'] == null || _workAddress['state']!.isEmpty ||
        _workAddress['municipality'] == null || _workAddress['municipality']!.isEmpty ||
        _workAddress['number'] == null || _workAddress['number']!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa la dirección del trabajo')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final vacancyData = {
        'employerId': uid,
        'jobTitle': _jobTitleController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        'remuneration': _remunerationController.text.trim().isEmpty ? 'A convenir' : _remunerationController.text.trim(),
        'remunerationUnit': _remunerationUnit,
        'workAddress': _workAddress,
        'requiredSkills': _requiredSkills,
        'schedule': _schedule.map((key, value) => MapEntry(key, value.map((r) => r.toJson()).toList())),
        'status': 'open',
        'applicantCount': 0,
        'matchedFreelancerId': null,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance.collection('vacancies').add(vacancyData);
      if (mounted) {
        context.pop(); // regresa al dashboard directamente
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al publicar: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalles de la vacante'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WFTextField(
                controller: _jobTitleController,
                label: 'Nombre del puesto *',
                hint: 'Ej: Cocinero',
                validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: WFTextField(
                      controller: _remunerationController,
                      label: 'Remuneración (opcional)',
                      hint: 'Ej: 1500',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _remunerationUnit,
                      decoration: const InputDecoration(
                        labelText: 'Unidad',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'hora', child: Text('por hora')),
                        DropdownMenuItem(value: 'día', child: Text('por día')),
                        DropdownMenuItem(value: 'turno', child: Text('por turno')),
                      ],
                      onChanged: (value) => setState(() => _remunerationUnit = value),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Dirección del trabajo', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              WFAddressIBGE(
                onAddressChanged: (address) => _workAddress = address,
              ),
              const SizedBox(height: 16),
              const Text('Habilidades requeridas (máx. 6)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              WFSkillsSelector(
                title: 'Selecciona habilidades',
                onSaved: (skills) => _requiredSkills = skills,
              ),
              const SizedBox(height: 16),
              WFTextField(
                controller: _descriptionController,
                label: 'Descripción (opcional)',
                hint: 'Detalles adicionales...',
                maxLines: 5,
              ),
              const SizedBox(height: 32),
              if (_isSaving)
                const Center(child: CircularProgressIndicator())
              else
                WFButton(
                  label: 'Publicar vacante',
                  onPressed: _saveVacancy,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

