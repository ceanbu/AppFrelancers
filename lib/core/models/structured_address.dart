class StructuredAddress {
  final String state;
  final String municipality;
  final String? neighborhood;
  final String? street;
  final String number;
  final String? complement;

  const StructuredAddress({
    required this.state,
    required this.municipality,
    this.neighborhood,
    this.street,
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

  factory StructuredAddress.fromMap(Map<String, dynamic> map) => StructuredAddress(
        state: map['state'] ?? '',
        municipality: map['municipality'] ?? '',
        neighborhood: map['neighborhood'],
        street: map['street'],
        number: map['number'] ?? '',
        complement: map['complement'],
      );

  @override
  String toString() {
    final parts = [
      if (street != null && street!.isNotEmpty) street,
      if (number.isNotEmpty) number,
      if (neighborhood != null && neighborhood!.isNotEmpty) neighborhood,
      municipality,
      state,
    ];
    return parts.join(', ');
  }
}
