import 'package:cloud_firestore/cloud_firestore.dart';
import '../../onboarding_freelancer/domain/freelancer.dart';

enum VacancyStatus { open, paused, filled, closed }

extension VacancyStatusExt on VacancyStatus {
  String get label {
    switch (this) {
      case VacancyStatus.open:
        return 'Abierta';
      case VacancyStatus.paused:
        return 'Pausada';
      case VacancyStatus.filled:
        return 'Cubierta';
      case VacancyStatus.closed:
        return 'Cerrada';
    }
  }

  static VacancyStatus fromString(String value) {
    return VacancyStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => VacancyStatus.open,
    );
  }
}

/// Colección: vacancies (Firestore)
class VacancyModel {
  final String id;
  final String employerId;
  final String jobTitle;
  final String? description;
  final String? remuneration;
  final String? remunerationUnit; // "hora", "día", "turno"
  final StructuredAddress workAddress;
  final List<String> requiredSkills; // máx 6
  final Map<String, List<TimeRange>> schedule; // "YYYY-MM-DD" → rangos
  final VacancyStatus status;
  final int applicantCount;
  final String? matchedFreelancerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const VacancyModel({
    required this.id,
    required this.employerId,
    required this.jobTitle,
    this.description,
    this.remuneration,
    this.remunerationUnit,
    required this.workAddress,
    required this.requiredSkills,
    required this.schedule,
    required this.status,
    required this.applicantCount,
    this.matchedFreelancerId,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'employerId': employerId,
        'jobTitle': jobTitle,
        'description': description,
        'remuneration': remuneration,
        'remunerationUnit': remunerationUnit,
        'workAddress': workAddress.toMap(),
        'requiredSkills': requiredSkills,
        'schedule': schedule.map(
          (k, v) => MapEntry(k, v.map((r) => r.toMap()).toList()),
        ),
        'status': status.name,
        'applicantCount': applicantCount,
        'matchedFreelancerId': matchedFreelancerId,
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  factory VacancyModel.fromMap(Map<String, dynamic> map) => VacancyModel(
        id: map['id'] ?? '',
        employerId: map['employerId'] ?? '',
        jobTitle: map['jobTitle'] ?? '',
        description: map['description'],
        remuneration: map['remuneration'],
        remunerationUnit: map['remunerationUnit'],
        workAddress: StructuredAddress.fromMap(map['workAddress'] ?? {}),
        requiredSkills: List<String>.from(map['requiredSkills'] ?? []),
        schedule: (map['schedule'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(
            k,
            (v as List).map((r) => TimeRange.fromMap(r)).toList(),
          ),
        ),
        status: VacancyStatusExt.fromString(map['status'] ?? 'open'),
        applicantCount: map['applicantCount'] ?? 0,
        matchedFreelancerId: map['matchedFreelancerId'],
        createdAt: (map['createdAt'] as Timestamp).toDate(),
        updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      );

  VacancyModel copyWith({
    String? jobTitle,
    String? description,
    String? remuneration,
    String? remunerationUnit,
    StructuredAddress? workAddress,
    List<String>? requiredSkills,
    Map<String, List<TimeRange>>? schedule,
    VacancyStatus? status,
    int? applicantCount,
    String? matchedFreelancerId,
  }) =>
      VacancyModel(
        id: id,
        employerId: employerId,
        jobTitle: jobTitle ?? this.jobTitle,
        description: description ?? this.description,
        remuneration: remuneration ?? this.remuneration,
        remunerationUnit: remunerationUnit ?? this.remunerationUnit,
        workAddress: workAddress ?? this.workAddress,
        requiredSkills: requiredSkills ?? this.requiredSkills,
        schedule: schedule ?? this.schedule,
        status: status ?? this.status,
        applicantCount: applicantCount ?? this.applicantCount,
        matchedFreelancerId: matchedFreelancerId ?? this.matchedFreelancerId,
        createdAt: createdAt,
        updatedAt: DateTime.now(),
      );
}

/// Estado de una postulación (RF3.4)
enum ApplicationStatus { pending, contacted, discarded, closed }

extension ApplicationStatusExt on ApplicationStatus {
  String get label {
    switch (this) {
      case ApplicationStatus.pending:
        return 'En Revisión';
      case ApplicationStatus.contacted:
        return 'Contactado';
      case ApplicationStatus.discarded:
        return 'Descartado';
      case ApplicationStatus.closed:
        return 'Vacante Cerrada';
    }
  }

  static ApplicationStatus fromString(String value) {
    return ApplicationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ApplicationStatus.pending,
    );
  }
}

/// Colección: applications (Firestore)
class ApplicationModel {
  final String id;
  final String vacancyId;
  final String freelancerId;
  final String employerId;
  final ApplicationStatus status;
  final bool blockedForFuture; // RF5.1.1
  final DateTime appliedAt;
  final DateTime? closedAt;

  const ApplicationModel({
    required this.id,
    required this.vacancyId,
    required this.freelancerId,
    required this.employerId,
    required this.status,
    required this.blockedForFuture,
    required this.appliedAt,
    this.closedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'vacancyId': vacancyId,
        'freelancerId': freelancerId,
        'employerId': employerId,
        'status': status.name,
        'blockedForFuture': blockedForFuture,
        'appliedAt': Timestamp.fromDate(appliedAt),
        'closedAt': closedAt != null ? Timestamp.fromDate(closedAt!) : null,
      };

  factory ApplicationModel.fromMap(Map<String, dynamic> map) =>
      ApplicationModel(
        id: map['id'] ?? '',
        vacancyId: map['vacancyId'] ?? '',
        freelancerId: map['freelancerId'] ?? '',
        employerId: map['employerId'] ?? '',
        status: ApplicationStatusExt.fromString(map['status'] ?? 'pending'),
        blockedForFuture: map['blockedForFuture'] ?? false,
        appliedAt: (map['appliedAt'] as Timestamp).toDate(),
        closedAt: map['closedAt'] != null
            ? (map['closedAt'] as Timestamp).toDate()
            : null,
      );
}
