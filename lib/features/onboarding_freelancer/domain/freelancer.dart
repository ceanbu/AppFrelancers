import 'package:workflex/core/models/time_range.dart';

class Freelancer {
  final String id;
  final String fullName;
  final String documentType;
  final String documentNumber;
  final DateTime birthDate;
  final String phone;
  final String email;
  final String? aboutMe;
  final Map<String, String> address;
  final List<String> skills;
  final List<Experience> experience;
  final Map<String, List<TimeRange>> availability;
  final DateTime createdAt;
  Freelancer({
    required this.id,
    required this.fullName,
    required this.documentType,
    required this.documentNumber,
    required this.birthDate,
    required this.phone,
    required this.email,
    this.aboutMe,
    required this.address,
    this.skills = const [],
    this.experience = const [],
    this.availability = const {},
    required this.createdAt,
  });
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'birthDate': birthDate.toIso8601String(),
      'phone': phone,
      'email': email,
      'aboutMe': aboutMe,
      'address': address,
      'skills': skills,
      'experience': experience.map((e) => e.toJson()).toList(),
      'availability': availability.map((key, value) => MapEntry(key, value.map((t) => t.toJson()).toList())),
      'createdAt': createdAt.toIso8601String(),
    };
  }
  factory Freelancer.fromJson(String id, Map<String, dynamic> json) {
    return Freelancer(
      id: id,
      fullName: json['fullName'],
      documentType: json['documentType'],
      documentNumber: json['documentNumber'],
      birthDate: DateTime.parse(json['birthDate']),
      phone: json['phone'],
      email: json['email'],
      aboutMe: json['aboutMe'],
      address: Map<String, String>.from(json['address']),
      skills: List<String>.from(json['skills']),
      experience: (json['experience'] as List).map((e) => Experience.fromJson(e)).toList(),
      availability: (json['availability'] as Map).map((key, value) => MapEntry(key, (value as List).map((t) => TimeRange.fromJson(t)).toList())),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

class Experience {
  final String company;
  final String role;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final bool isCurrent;
  Experience({
    required this.company,
    required this.role,
    required this.startDate,
    this.endDate,
    this.description,
    this.isCurrent = false,
  });
  Map<String, dynamic> toJson() => {
    'company': company,
    'role': role,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'description': description,
    'isCurrent': isCurrent,
  };
  factory Experience.fromJson(Map<String, dynamic> json) => Experience(
    company: json['company'],
    role: json['role'],
    startDate: DateTime.parse(json['startDate']),
    endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    description: json['description'],
    isCurrent: json['isCurrent'],
  );
}