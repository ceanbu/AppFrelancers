class Estado {
  final int id;
  final String sigla;
  final String nome;

  Estado({required this.id, required this.sigla, required this.nome});

  factory Estado.fromJson(Map<String, dynamic> json) {
    return Estado(
      id: json['id'] as int,
      sigla: json['sigla'] as String,
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
      other is Estado &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
