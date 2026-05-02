import 'package:cloud_firestore/cloud_firestore.dart';

/// Tipos de documento disponibles (RF1.2)
enum DocumentType { cpf, rg, rnm, crnm }

extension DocumentTypeExt on DocumentType {
  String get label {
    switch (this) {
      case DocumentType.cpf:
        return 'CPF';
      case DocumentType.rg:
        return 'RG';
      case DocumentType.rnm:
        return 'RNM';
      case DocumentType.crnm:
        return 'CRNM';
    }
  }

  static DocumentType fromString(String value) {
    return DocumentType.values.firstWhere(
      (e) => e.name == value.toLowerCase(),
      orElse: () => DocumentType.cpf,
    );
  }
}

/// Dirección estructurada (RF1.2 / RF1.5 / RF2.2.B)
class StructuredAddress {
  final String state;        // via IBGE
  final String municipality; // via IBGE
  final String neighborhood;
  final String street;
  final String number;
  final String? complement;

  const StructuredAddress({
    required this.state,
    required this.municipality,
    required this.neighborhood,
    required this.street,
    required this.number,
    this.complement,
  });

  Map<String, dynamic> toMap() => {
        'state': state,
        'municipality': municipality,
        'neighborhood': neighborhood,
        'street': street,
        'number': number,
        'complement': complement,
      };

  factory StructuredAddress.fromMap(Map<String, dynamic> map) =>
      StructuredAddress(
        state: map['state'] ?? '',
        municipality: map['municipality'] ?? '',
        neighborhood: map['neighborhood'] ?? '',
        street: map['street'] ?? '',
        number: map['number'] ?? '',
        complement: map['complement'],
      );
}

/// Experiencia laboral (RF1.8)
class WorkExperience {
  final String id;
  final String company;
  final String position;
  final String startMonth; // "MM/YYYY"
  final String? endMonth;  // null = "Trabajo actual"
  final String? description;

  const WorkExperience({
    required this.id,
    required this.company,
    required this.position,
    required this.startMonth,
    this.endMonth,
    this.description,
  });

  bool get isCurrent => endMonth == null;

  Map<String, dynamic> toMap() => {
        'id': id,
        'company': company,
        'position': position,
        'startMonth': startMonth,
        'endMonth': endMonth,
        'description': description,
      };

  factory WorkExperience.fromMap(Map<String, dynamic> map) => WorkExperience(
        id: map['id'] ?? '',
        company: map['company'] ?? '',
        position: map['position'] ?? '',
        startMonth: map['startMonth'] ?? '',
        endMonth: map['endMonth'],
        description: map['description'],
      );
}

/// Rango horario (RF1.3 / RF2.2.A)
class TimeRange {
  final String startTime; // "HH:MM"
  final String endTime;   // "HH:MM"

  const TimeRange({required this.startTime, required this.endTime});

  Map<String, dynamic> toMap() => {
        'startTime': startTime,
        'endTime': endTime,
      };

  factory TimeRange.fromMap(Map<String, dynamic> map) => TimeRange(
        startTime: map['startTime'] ?? '00:00',
        endTime: map['endTime'] ?? '00:00',
      );
}

/// Colección: freelancers (Firestore)
class FreelancerModel {
  final String uid;
  final String fullName;
  final String email;
  final String phone;
  final DocumentType documentType;
  final String documentNumber; // cifrado en Firestore
  final DateTime dateOfBirth;
  final String? aboutMe;
  final StructuredAddress address;
  final List<String> skills;          // máx 6 (RF1.4)
  final Map<String, List<TimeRange>> availability; // "YYYY-MM-DD" → rangos
  final List<WorkExperience> experience;
  final DateTime createdAt;

  const FreelancerModel({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.documentType,
    required this.documentNumber,
    required this.dateOfBirth,
    this.aboutMe,
    required this.address,
    required this.skills,
    required this.availability,
    required this.experience,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'documentType': documentType.name,
        'documentNumber': documentNumber,
        'dateOfBirth': Timestamp.fromDate(dateOfBirth),
        'aboutMe': aboutMe,
        'address': address.toMap(),
        'skills': skills,
        'availability': availability.map(
          (k, v) => MapEntry(k, v.map((r) => r.toMap()).toList()),
        ),
        'experience': experience.map((e) => e.toMap()).toList(),
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory FreelancerModel.fromMap(Map<String, dynamic> map) => FreelancerModel(
        uid: map['uid'] ?? '',
        fullName: map['fullName'] ?? '',
        email: map['email'] ?? '',
        phone: map['phone'] ?? '',
        documentType: DocumentTypeExt.fromString(map['documentType'] ?? 'cpf'),
        documentNumber: map['documentNumber'] ?? '',
        dateOfBirth: (map['dateOfBirth'] as Timestamp).toDate(),
        aboutMe: map['aboutMe'],
        address: StructuredAddress.fromMap(map['address'] ?? {}),
        skills: List<String>.from(map['skills'] ?? []),
        availability: (map['availability'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(
            k,
            (v as List).map((r) => TimeRange.fromMap(r)).toList(),
          ),
        ),
        experience: (map['experience'] as List? ?? [])
            .map((e) => WorkExperience.fromMap(e))
            .toList(),
        createdAt: (map['createdAt'] as Timestamp).toDate(),
      );
}

/// Datos del Representante Legal del Empleador (RF1.5)
class LegalRepresentative {
  final DocumentType documentType;
  final String documentNumber; // cifrado
  final DateTime dateOfBirth;
  final String phone;

  const LegalRepresentative({
    required this.documentType,
    required this.documentNumber,
    required this.dateOfBirth,
    required this.phone,
  });

  Map<String, dynamic> toMap() => {
        'documentType': documentType.name,
        'documentNumber': documentNumber,
        'dateOfBirth': Timestamp.fromDate(dateOfBirth),
        'phone': phone,
      };

  factory LegalRepresentative.fromMap(Map<String, dynamic> map) =>
      LegalRepresentative(
        documentType: DocumentTypeExt.fromString(map['documentType'] ?? 'cpf'),
        documentNumber: map['documentNumber'] ?? '',
        dateOfBirth: (map['dateOfBirth'] as Timestamp).toDate(),
        phone: map['phone'] ?? '',
      );
}

/// Colección: employers (Firestore)
class EmployerModel {
  final String uid;
  final String email;
  final String businessName;
  final String businessType;
  final LegalRepresentative representative;
  final StructuredAddress businessAddress;
  final int credits;
  final DateTime createdAt;

  const EmployerModel({
    required this.uid,
    required this.email,
    required this.businessName,
    required this.businessType,
    required this.representative,
    required this.businessAddress,
    required this.credits,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'email': email,
        'businessName': businessName,
        'businessType': businessType,
        'representativeInfo': representative.toMap(),
        'address': businessAddress.toMap(),
        'credits': credits,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory EmployerModel.fromMap(Map<String, dynamic> map) => EmployerModel(
        uid: map['uid'] ?? '',
        email: map['email'] ?? '',
        businessName: map['businessName'] ?? '',
        businessType: map['businessType'] ?? '',
        representative:
            LegalRepresentative.fromMap(map['representativeInfo'] ?? {}),
        businessAddress: StructuredAddress.fromMap(map['address'] ?? {}),
        credits: map['credits'] ?? 0,
        createdAt: (map['createdAt'] as Timestamp).toDate(),
      );
}
