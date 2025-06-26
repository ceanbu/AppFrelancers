class Freelancer {
  String fullName;
  String documentType; // CPF, RG, RNM, CRNM
  String documentNumber;
  DateTime dateOfBirth;
  String phone;
  String email;
  String password;
  String stateId; // UF ID (e.g., "SP" or "35")
  String cityId; // IBGE City ID
  String neighborhood;
  String street;
  String number;
  String? complement;

  Freelancer({
    required this.fullName,
    required this.documentType,
    required this.documentNumber,
    required this.dateOfBirth,
    required this.phone,
    required this.email,
    required this.password,
    required this.stateId,
    required this.cityId,
    required this.neighborhood,
    required this.street,
    required this.number,
    this.complement,
  });

  // Método toJson para convertir el objeto Freelancer a un mapa JSON.
  // Útil para enviar datos a un backend.
  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'documentType': documentType,
      'documentNumber': documentNumber,
      'dateOfBirth': dateOfBirth.toIso8601String(), // Formato estándar para fechas
      'phone': phone,
      'email': email,
      // No incluir la contraseña en toJson por seguridad si no es necesario.
      // 'password': password,
      'address': {
        'stateId': stateId,
        'cityId': cityId,
        'neighborhood': neighborhood,
        'street': street,
        'number': number,
        'complement': complement,
      }
    };
  }

  // Puedes añadir un método fromJson si necesitas crear un Freelancer desde un mapa JSON.
  // factory Freelancer.fromJson(Map<String, dynamic> json) {
  //   return Freelancer(
  //     fullName: json['fullName'],
  //     documentId: json['documentId'],
  //     dateOfBirth: DateTime.parse(json['dateOfBirth']),
  //     phone: json['phone'],
  //     email: json['email'],
  //     password: '', // No recuperar contraseña así
  //     stateId: json['address']['stateId'],
  //     cityId: json['address']['cityId'],
  //     neighborhood: json['address']['neighborhood'],
  //     street: json['address']['street'],
  //     number: json['address']['number'],
  //     complement: json['address']['complement'],
  //   );
  // }
}
