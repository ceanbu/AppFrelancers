import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workflex/core/constants/app_colors.dart';
import 'package:workflex/core/constants/app_text_styles.dart';

class ApplicantsListScreen extends StatefulWidget {
  final String vacancyId;
  const ApplicantsListScreen({super.key, required this.vacancyId});

  @override
  State<ApplicantsListScreen> createState() => _ApplicantsListScreenState();
}

class _ApplicantsListScreenState extends State<ApplicantsListScreen> {
  List<Map<String, dynamic>> _applicants = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplicants();
  }

  Future<void> _loadApplicants() async {
    setState(() => _isLoading = true);
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('applications')
          .where('vacantId', isEqualTo: widget.vacancyId)
          .where('status', isEqualTo: 'pending')
          .get();
      debugPrint('?? Aplicaciones en lista: ${snapshot.docs.length}');
      final List<Map<String, dynamic>> applicantsList = [];
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final freelancerDoc = await FirebaseFirestore.instance
            .collection('freelancers')
            .doc(data['freelancerId'])
            .get();
        if (freelancerDoc.exists) {
          applicantsList.add({
            'applicationId': doc.id,
            'freelancerId': data['freelancerId'],
            'name': freelancerDoc['fullName'] ?? 'Sin nombre',
            'skills': List<String>.from(freelancerDoc['skills'] ?? []),
            'phone': freelancerDoc['phone'] ?? '',
          });
        }
      }
      setState(() => _applicants = applicantsList);
      debugPrint('? Postulantes cargados: ${_applicants.length}');
    } catch (e) {
      debugPrint('? Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _makeMatch(String applicationId, String freelancerId, String phone) async {
    try {
      await FirebaseFirestore.instance.collection('applications').doc(applicationId).update({
        'status': 'contacted',
      });
      await FirebaseFirestore.instance.collection('vacancies').doc(widget.vacancyId).update({
        'matchedFreelancerId': freelancerId,
        'status': 'filled',
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match realizado con éxito')),
      );
      final whatsappUrl = 'https://wa.me/${phone.replaceAll(RegExp(r'[^\d+]'), '')}?text=Hola!%20Has%20sido%20seleccionado%20para%20la%20vacante.';
      if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
        await launchUrl(Uri.parse(whatsappUrl));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
      context.pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Postulantes', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _applicants.isEmpty
              ? const Center(child: Text('No hay postulantes pendientes.'))
              : ListView.builder(
                  itemCount: _applicants.length,
                  itemBuilder: (context, index) {
                    final applicant = _applicants[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(applicant['name'], style: AppTextStyles.titleMedium),
                            const SizedBox(height: 4),
                            Text('Habilidades: ${(applicant['skills'] as List).join(', ')}',
                                style: AppTextStyles.bodySmall),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () => _makeMatch(
                                      applicant['applicationId'],
                                      applicant['freelancerId'],
                                      applicant['phone']),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                  ),
                                  child: const Text('Seleccionar'),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: () async {
                                    await FirebaseFirestore.instance
                                        .collection('applications')
                                        .doc(applicant['applicationId'])
                                        .update({'status': 'discarded'});
                                    _loadApplicants();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                  ),
                                  child: const Text('Descartar'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

