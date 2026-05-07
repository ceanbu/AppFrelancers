import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workflex/core/widgets/wf_calendar.dart';
import 'package:workflex/core/models/time_range.dart';
import 'package:workflex/core/constants/app_colors.dart';
import 'package:workflex/core/constants/app_text_styles.dart';

class EditAvailabilityScreen extends StatefulWidget {
  final Map<String, List<TimeRange>> currentAvailability;
  const EditAvailabilityScreen({super.key, required this.currentAvailability});

  @override
  State<EditAvailabilityScreen> createState() => _EditAvailabilityScreenState();
}

class _EditAvailabilityScreenState extends State<EditAvailabilityScreen> {
  late Map<String, List<TimeRange>> _availability;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Copiar la disponibilidad actual para editarla
    _availability = Map.from(widget.currentAvailability);
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final availabilityMap = _availability.map((key, ranges) => MapEntry(key, ranges.map((r) => r.toJson()).toList()));
      await FirebaseFirestore.instance.collection('freelancers').doc(uid).update({
        'availability': availabilityMap,
      });
      if (mounted) {
        Navigator.pop(context, true); // Devuelve true para indicar que hubo cambios
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
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
        title: Text('Editar disponibilidad', style: AppTextStyles.headlineMedium),
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
            child: WFCalendar(
              initialAvailability: _availability,
              onChanged: (newAvailability) => setState(() => _availability = newAvailability),
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
