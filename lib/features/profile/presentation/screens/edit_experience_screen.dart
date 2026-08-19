import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workflex/core/constants/app_colors.dart';
import 'package:workflex/core/constants/app_text_styles.dart';
// Reutilizamos el formulario ya existente del onboarding en vez de duplicarlo.
import 'package:workflex/features/onboarding_freelancer/presentation/screens/step4_experience_screen.dart'
    show ExperienceForm;

class EditExperienceScreen extends StatefulWidget {
  final List<Map<String, dynamic>> currentExperience;
  const EditExperienceScreen({super.key, required this.currentExperience});

  @override
  State<EditExperienceScreen> createState() => _EditExperienceScreenState();
}

class _EditExperienceScreenState extends State<EditExperienceScreen> {
  late List<Map<String, dynamic>> _experiences;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _experiences =
        widget.currentExperience.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> _addExperience() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ExperienceForm()),
    );
    if (result != null) setState(() => _experiences.add(result));
  }

  Future<void> _editExperience(int index) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ExperienceForm(initialData: _experiences[index])),
    );
    if (result != null) setState(() => _experiences[index] = result);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('freelancers').doc(uid).update({
        'experience': _experiences
            .map((e) => {
                  'company': e['company'],
                  'position': e['position'],
                  'startDate': e['startDate'],
                  'endDate': e['isCurrent'] == true ? null : e['endDate'],
                  'isCurrent': e['isCurrent'],
                  'description': e['description'] ?? '',
                })
            .toList(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Editar experiencia laboral', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
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
                      final start = exp['startDate'] ?? '';
                      final end = exp['isCurrent'] == true ? 'Actual' : (exp['endDate'] ?? '');
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: ListTile(
                          title: Text(exp['position'] ?? ''),
                          subtitle: Text('${exp['company'] ?? ''} · $start - $end'),
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
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              onPressed: _addExperience,
              icon: const Icon(Icons.add),
              label: const Text('Agregar experiencia'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Guardar cambios'),
            ),
          ),
        ],
      ),
    );
  }
}
