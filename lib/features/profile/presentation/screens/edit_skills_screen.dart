import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workflex/core/widgets/wf_skills_selector.dart';
import 'package:workflex/core/constants/app_colors.dart';
import 'package:workflex/core/constants/app_text_styles.dart';

class EditSkillsScreen extends StatefulWidget {
  final List<String> currentSkills;
  const EditSkillsScreen({super.key, required this.currentSkills});

  @override
  State<EditSkillsScreen> createState() => _EditSkillsScreenState();
}

class _EditSkillsScreenState extends State<EditSkillsScreen> {
  late List<String> _skills;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _skills = List.from(widget.currentSkills);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('freelancers').doc(uid).update({
        'skills': _skills,
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
        title: Text('Editar habilidades', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: WFSkillsSelector(
                title: 'Tus habilidades (máximo 6)',
                initialSelected: _skills,
                // IMPORTANTE: WFSkillsSelector llama a onSaved() en cada toggle,
                // no solo al confirmar (no tiene botón propio de "Guardar
                // habilidades" pese a que RF1.4.5 lo documenta desde V1.7).
                // Por eso acá NO escribimos a Firestore dentro de este callback,
                // solo actualizamos la selección local. El guardado real ocurre
                // recién al presionar "Guardar cambios" más abajo.
                onSaved: (skills) => setState(() => _skills = skills),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
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
          ],
        ),
      ),
    );
  }
}
