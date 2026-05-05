import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/wf_skills_selector.dart';

class Step3SkillsScreen extends StatefulWidget {
  const Step3SkillsScreen({super.key});

  @override
  State<Step3SkillsScreen> createState() => _Step3SkillsScreenState();
}

class _Step3SkillsScreenState extends State<Step3SkillsScreen> {
  bool _isSaving = false;

  Future<void> _saveSkills(List<String> skills) async {
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('freelancers').doc(uid).update({
        'skills': skills,
      });
      if (mounted) {
        context.go('/freelancer/register/step4');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ')));
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Paso 3 - Habilidades'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _isSaving
              ? const Center(child: CircularProgressIndicator())
              : WFSkillsSelector(
                  title: 'Selecciona tus habilidades (máximo 6)',
                  onSaved: _saveSkills,
                ),
        ),
      ),
    );
  }
}
