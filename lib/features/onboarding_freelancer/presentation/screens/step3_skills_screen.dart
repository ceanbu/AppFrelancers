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
  List<String> _selectedSkills = [];
  bool _isSaving = false;

  Future<void> _saveAndContinue() async {
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('freelancers').doc(uid).update({
        'skills': _selectedSkills,
      });
      if (mounted) {
        context.go('/freelancer/register/step4');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

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
          title: const Text('Paso 3 - Habilidades'),
        ),
        body: _isSaving
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: WFSkillsSelector(
                        title: 'Selecciona tus habilidades (máximo 6)',
                        // BUG ENCONTRADO EN AUDITORÍA: WFSkillsSelector llama a
                        // onSaved() en cada toggle, no solo al confirmar — no
                        // tiene botón propio de "Guardar habilidades" pese a que
                        // RF1.4.5 lo documenta desde V1.7. Antes de este fix,
                        // onSaved estaba conectado directamente a un método que
                        // escribía en Firestore Y navegaba a Step4, por lo que
                        // el primer tap en una habilidad sacaba al usuario de la
                        // pantalla antes de poder elegir más de una.
                        // Acá solo actualizamos la selección local; el guardado
                        // real y el avance de paso ocurren recién al presionar
                        // "Guardar y continuar".
                        onSaved: (skills) => setState(() => _selectedSkills = skills),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: (_selectedSkills.isEmpty || _isSaving) ? null : _saveAndContinue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      child: const Text('Guardar y continuar'),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
