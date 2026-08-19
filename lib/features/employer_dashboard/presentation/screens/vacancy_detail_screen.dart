import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:workflex/core/constants/app_colors.dart';
import 'package:workflex/core/constants/app_text_styles.dart';

class VacancyDetailScreen extends StatefulWidget {
  final String vacancyId;
  const VacancyDetailScreen({super.key, required this.vacancyId});

  @override
  State<VacancyDetailScreen> createState() => _VacancyDetailScreenState();
}

class _VacancyDetailScreenState extends State<VacancyDetailScreen> {
  String _buildWhatsAppUrl(String rawPhone) {
    var digits = rawPhone.replaceAll(RegExp(r'[^\d]'), '');
    if (!digits.startsWith('55') && (digits.length == 10 || digits.length == 11)) {
      digits = '55' + digits;
    }
    return 'https://wa.me/' + digits + '?text=Hola!%20Has%20sido%20seleccionado%20para%20la%20vacante.';
  }

  Future<void> _openWhatsApp(String phone) async {
    final url = _buildWhatsAppUrl(phone);
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se pudo abrir WhatsApp. Verifica que este instalado.')),
        );
      }
    }
  }
  late Future<DocumentSnapshot> _vacancyFuture;
  List<Map<String, dynamic>> _applicants = [];
  String? _matchedFreelancerId;
  String? _status;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _vacancyFuture = FirebaseFirestore.instance.collection('vacancies').doc(widget.vacancyId).get();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await _loadApplicants();
    final vacancyDoc = await FirebaseFirestore.instance.collection('vacancies').doc(widget.vacancyId).get();
    if (vacancyDoc.exists) {
      setState(() {
        _status = vacancyDoc.data()?['status'];
        _matchedFreelancerId = vacancyDoc.data()?['matchedFreelancerId'];
      });
    }
    setState(() => _isLoading = false);
  }

  Future<void> _loadApplicants() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('applications')
          .where('vacancyId', isEqualTo: widget.vacancyId)
          .where('status', whereIn: ['pending', 'contacted'])
          .get();
      debugPrint('Aplicaciones encontradas: ${snapshot.docs.length}');
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
            'experience': freelancerDoc['experience'] ?? [],
            'phone': freelancerDoc['phone'] ?? '',
            'availability': freelancerDoc['availability'] ?? {},
          });
        }
      }
      setState(() => _applicants = applicantsList);
    } catch (e) {
      debugPrint('Error cargando postulantes: $e');
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
      setState(() {
        _matchedFreelancerId = freelancerId;
        _status = 'filled';
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Match realizado con exito')),
      );
      await _openWhatsApp(phone);
      _loadApplicants();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _reactivateIfNoActiveApplicants() async {
    final remaining = await FirebaseFirestore.instance
        .collection('applications')
        .where('vacancyId', isEqualTo: widget.vacancyId)
        .where('status', whereIn: ['pending', 'contacted'])
        .get();
    if (remaining.docs.isEmpty && _status == 'paused') {
      await FirebaseFirestore.instance.collection('vacancies').doc(widget.vacancyId).update({
        'status': 'open',
      });
      if (mounted) setState(() => _status = 'open');
    }
  }

  Future<void> _discardApplication(String applicationId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Descartar postulante'),
        content: const Text('Que accion deseas realizar?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Descartar solo esta vacante')),
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Bloquear para futuras ofertas')),
        ],
      ),
    );
    if (result == true) {
      await FirebaseFirestore.instance.collection('applications').doc(applicationId).update({
        'status': 'discarded',
      });
      await _reactivateIfNoActiveApplicants();
      _loadApplicants();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postulante descartado')),
      );
    }
  }

  void _editVacancy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('La edicion de vacantes estara disponible pronto')),
    );
  }

  Map<String, dynamic>? _getMatchedFreelancer() {
    for (var applicant in _applicants) {
      if (applicant['freelancerId'] == _matchedFreelancerId) {
        return applicant;
      }
    }
    return null;
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
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editVacancy,
            tooltip: 'Editar vacante',
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _vacancyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Vacante no encontrada'));
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final workAddress = (data['workAddress'] as Map<String, dynamic>?) ?? {};
          final schedule = data['schedule'] as Map<String, dynamic>? ?? {};
          final scheduleSummary = schedule.isNotEmpty
              ? 'Disponible en ${schedule.keys.length} dia(s)'
              : 'Sin horarios definidos';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(data['jobTitle'] ?? '', style: AppTextStyles.displayMedium),
                    Chip(
                      label: Text(_statusText(_status ?? 'open')),
                      backgroundColor: _statusColor(_status ?? 'open').withOpacity(0.2),
                      labelStyle: TextStyle(color: _statusColor(_status ?? 'open')),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (data['remuneration'] != null)
                  Text('Remuneracion: ${data['remuneration']} ${data['remunerationUnit'] ?? ''}',
                      style: AppTextStyles.titleMedium),
                const SizedBox(height: 16),
                Text('Direccion', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  '${workAddress['street'] ?? ''} ${workAddress['number'] ?? ''}, ${workAddress['neighborhood'] ?? ''}\n${workAddress['municipality'] ?? ''} - ${workAddress['state'] ?? ''}',
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
                    label: Text(skill.toString(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
                    backgroundColor: AppColors.primary,
                  )).toList(),
                ),
                const SizedBox(height: 16),
                if (data['description'] != null && data['description'].isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Descripcion', style: AppTextStyles.headlineMedium),
                      const SizedBox(height: 4),
                      Text(data['description'], style: AppTextStyles.bodyMedium),
                    ],
                  ),
                const SizedBox(height: 24),
                if (_matchedFreelancerId != null && _matchedFreelancerId!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final freelancer = _getMatchedFreelancer();
                        if (freelancer != null) {
                          final phone = freelancer['phone'];
                          _openWhatsApp(phone);
                        }
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Contactar por WhatsApp'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    ),
                  ),
                if (_status != 'filled' && _status != 'closed') _buildApplicantsSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildApplicantsSection() {
    if (_applicants.isEmpty) {
      if (_isLoading) return const SizedBox.shrink();
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('No hay postulantes aun.', style: AppTextStyles.bodyMedium),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Postulantes (${_applicants.length})', style: AppTextStyles.headlineMedium),
            TextButton(
              onPressed: () => context.push('/employer/vacancy/${widget.vacancyId}/applicants'),
              child: const Text('Ver todos'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _applicants.length > 5 ? 5 : _applicants.length,
            itemBuilder: (context, index) {
              final applicant = _applicants[index];
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(applicant['name'], style: AppTextStyles.titleMedium),
                        const SizedBox(height: 4),
                        Text('Habilidades: ${(applicant['skills'] as List).join(', ')}', style: AppTextStyles.bodySmall),
                        const SizedBox(height: 4),
                        Text('Experiencia: ${(applicant['experience'] as List).length} registro(s)', style: AppTextStyles.bodySmall),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: TextButton(
                                onPressed: () => context.push('/employer/freelancer-profile/${applicant['freelancerId']}'),
                                child: const Text('Ver perfil'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: ElevatedButton(
                                onPressed: () => _makeMatch(applicant['applicationId'], applicant['freelancerId'], applicant['phone']),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 12)),
                                child: const Text('Seleccionar'),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _discardApplication(applicant['applicationId']),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _statusText(String status) {
    switch (status) {
      case 'open': return 'Abierta';
      case 'paused': return 'Pausada';
      case 'filled': return 'Cubierta';
      default: return 'Cerrada';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'open': return Colors.green;
      case 'paused': return Colors.orange;
      case 'filled': return Colors.blue;
      default: return Colors.grey;
    }
  }
}