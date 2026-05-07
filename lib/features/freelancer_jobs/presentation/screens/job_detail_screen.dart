import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workflex/core/models/time_range.dart';
import 'package:workflex/core/constants/app_colors.dart';
import 'package:workflex/core/constants/app_text_styles.dart';

class JobDetailScreen extends StatefulWidget {
  final String jobId;
  const JobDetailScreen({super.key, required this.jobId});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  late Future<DocumentSnapshot> _vacancyFuture;
  bool _isApplying = false;
  bool _alreadyApplied = false;

  @override
  void initState() {
    super.initState();
    _vacancyFuture = FirebaseFirestore.instance.collection('vacancies').doc(widget.jobId).get();
    _checkIfAlreadyApplied();
  }

  Future<void> _checkIfAlreadyApplied() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final existing = await FirebaseFirestore.instance
        .collection('applications')
        .where('vacantId', isEqualTo: widget.jobId)
        .where('freelancerId', isEqualTo: uid)
        .get();
    if (existing.docs.isNotEmpty) {
      setState(() => _alreadyApplied = true);
    }
  }

  Future<void> _apply() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión')),
      );
      return;
    }
    if (_alreadyApplied) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ya te postulaste a esta vacante')),
      );
      return;
    }

    setState(() => _isApplying = true);
    try {
      final vacancyDoc = await _vacancyFuture;
      final vacancyData = vacancyDoc.data() as Map<String, dynamic>;
      final employerId = vacancyData['employerId'];

      await FirebaseFirestore.instance.collection('applications').add({
        'vacantId': widget.jobId,
        'freelancerId': uid,
        'employerId': employerId,
        'status': 'pending',
        'blockedForFuture': false,
        'appliedAt': FieldValue.serverTimestamp(),
        'closedAt': null,
      });

      final newCount = (vacancyData['applicantCount'] ?? 0) + 1;
      await FirebaseFirestore.instance.collection('vacancies').doc(widget.jobId).update({
        'applicantCount': newCount,
      });
      if (newCount >= 5) {
        await FirebaseFirestore.instance.collection('vacancies').doc(widget.jobId).update({
          'status': 'paused',
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Postulación enviada con éxito!')),
        );
        setState(() => _alreadyApplied = true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al postular: ')),
      );
    } finally {
      setState(() => _isApplying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Detalle de vacante'),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _vacancyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: '));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Vacante no encontrada'));
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final schedule = data['schedule'] as Map<String, dynamic>? ?? {};
          final scheduleSummary = schedule.isNotEmpty
              ? 'Disponible en  día(s)'
              : 'Sin horarios definidos';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['jobTitle'] ?? '', style: AppTextStyles.displayMedium),
                const SizedBox(height: 8),
                if (data['remuneration'] != null)
                  Text('Remuneración:  ',
                      style: AppTextStyles.titleMedium),
                const SizedBox(height: 16),
                Text('Dirección', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  ' , \n - ',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 16),
                Text('Horarios', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 4),
                Text(scheduleSummary, style: AppTextStyles.bodyMedium),
                const SizedBox(height: 16),
                Text('Habilidades requeridas', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: (data['requiredSkills'] as List? ?? []).map<Widget>((skill) => Chip(
                    label: Text(skill),
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                if (data['description'] != null && data['description'].isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Descripción', style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 4),
                      Text(data['description'], style: AppTextStyles.bodyMedium),
                    ],
                  ),
                const SizedBox(height: 32),
                Center(
                  child: _alreadyApplied
                      ? const Text('Ya te postulaste', style: TextStyle(color: Colors.green))
                      : ElevatedButton(
                          onPressed: _isApplying ? null : _apply,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(200, 48),
                          ),
                          child: _isApplying
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('Postularme'),
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
