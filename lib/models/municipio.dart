class Municipio {
  final int id;
  final String nome;

  Municipio({required this.id, required this.nome});

  factory Municipio.fromJson(Map<String, dynamic> json) {
    return Municipio(
      id: json['id'] as int,
      nome: json['nome'] as String,
    );
  }

  // Para facilitar el uso en DropdownButtonFormField
  @override
  String toString() {
    return nome;
  }

  // Es buena práctica sobreescribir == y hashCode si vas a comparar instancias
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Municipio &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
