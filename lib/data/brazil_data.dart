class BrazilData {
  // Lista de estados con ID y nombre
  static List<Map<String, dynamic>> getEstados() {
    return [
      {'id': 11, 'nome': 'Rondônia'},
      {'id': 12, 'nome': 'Acre'},
      {'id': 13, 'nome': 'Amazonas'},
      {'id': 14, 'nome': 'Roraima'},
      {'id': 15, 'nome': 'Pará'},
      {'id': 16, 'nome': 'Amapá'},
      {'id': 17, 'nome': 'Tocantins'},
      {'id': 21, 'nome': 'Maranhão'},
      {'id': 22, 'nome': 'Piauí'},
      {'id': 23, 'nome': 'Ceará'},
      {'id': 24, 'nome': 'Rio Grande do Norte'},
      {'id': 25, 'nome': 'Paraíba'},
      {'id': 26, 'nome': 'Pernambuco'},
      {'id': 27, 'nome': 'Alagoas'},
      {'id': 28, 'nome': 'Sergipe'},
      {'id': 29, 'nome': 'Bahia'},
      {'id': 31, 'nome': 'Minas Gerais'},
      {'id': 32, 'nome': 'Espírito Santo'},
      {'id': 33, 'nome': 'Rio de Janeiro'},
      {'id': 35, 'nome': 'São Paulo'},
      {'id': 41, 'nome': 'Paraná'},
      {'id': 42, 'nome': 'Santa Catarina'},
      {'id': 43, 'nome': 'Rio Grande do Sul'},
      {'id': 50, 'nome': 'Mato Grosso do Sul'},
      {'id': 51, 'nome': 'Mato Grosso'},
      {'id': 52, 'nome': 'Goiás'},
      {'id': 53, 'nome': 'Distrito Federal'},
    ];
  }

  // Mapa de municipios por ID del estado
  static Map<int, List<String>> getMunicipiosPorEstado() {
    return {
      // São Paulo (SP)
      35: [
        'São Paulo', 'Guarulhos', 'Campinas', 'São Bernardo do Campo', 'Santo André',
        'São José dos Campos', 'Ribeirão Preto', 'Sorocaba', 'Santos', 'Mogi das Cruzes',
        'São José do Rio Preto', 'Jundiaí', 'Piracicaba', 'Carapicuíba', 'Itaquaquecetuba',
        'Bauru', 'São Vicente', 'Mauá', 'Diadema', 'São Carlos', 'Franca', 'Praia Grande',
        'Guarujá', 'Taubaté', 'Limeira', 'Sumaré', 'Taboão da Serra', 'Barueri', 'Embu das Artes',
        'Suzano', 'Cubatão', 'Itapevi', 'Rio Claro', 'Cotia', 'Indaiatuba', 'Ferraz de Vasconcelos',
        'Francisco Morato', 'Itapecerica da Serra', 'Itu', 'Bragança Paulista', 'Pindamonhangaba',
        'São Caetano do Sul', 'Itapetininga', 'Mogi Guaçu', 'Jaú', 'Botucatu', 'Araraquara',
        'Atibaia', 'São João da Boa Vista', 'Barretos', 'Sertãozinho', 'Catanduva', 'Caraguatatuba',
        'Tatuí', 'Ourinhos', 'Votorantim', 'Araçatuba', 'Rio Grande da Serra', 'Poá',
        'São Roque', 'Leme', 'Bebedouro', 'Pirassununga', 'São Sebastião', 'Salto', 'Tupã',
        'Lins', 'Fernandópolis'
      ],
      // Rio de Janeiro (RJ)
      33: [
        'Rio de Janeiro', 'São Gonçalo', 'Duque de Caxias', 'Nova Iguaçu', 'Niterói',
        'Belford Roxo', 'São João de Meriti', 'Campos dos Goytacazes', 'Petrópolis', 'Volta Redonda',
        'Magé', 'Itaboraí', 'Macaé', 'Nova Friburgo', 'Barra Mansa', 'Mesquita', 'Cabo Frio',
        'Nilópolis', 'Teresópolis', 'Angra dos Reis', 'Queimados', 'Resende', 'Araruama',
        'Itaguaí', 'Rio das Ostras', 'Mangaratiba', 'São Pedro da Aldeia', 'Maricá'
      ],
      // Minas Gerais (MG)
      31: [
        'Belo Horizonte', 'Uberlândia', 'Contagem', 'Juiz de Fora', 'Betim',
        'Montes Claros', 'Ribeirão das Neves', 'Uberaba', 'Governador Valadares', 'Ipatinga',
        'Santa Luzia', 'Sete Lagoas', 'Divinópolis', 'Ibirité', 'Poços de Caldas',
        'Patos de Minas', 'Teófilo Otoni', 'Pouso Alegre', 'Barbacena', 'Sabará',
        'Varginha', 'Conselheiro Lafaiete', 'Itabira', 'Passos', 'Araguari', 'Coronel Fabriciano',
        'Itajubá', 'Lavras', 'Pará de Minas', 'Timóteo', 'Muriaé', 'Unaí', 'Curvelo',
        'Nova Lima', 'Cataguases', 'João Monlevade', 'Três Corações', 'Viçosa', 'Ouro Preto'
      ],
      // Bahia (BA)
      29: [
        'Salvador', 'Feira de Santana', 'Vitória da Conquista', 'Camaçari', 'Itabuna',
        'Juazeiro', 'Lauro de Freitas', 'Ilhéus', 'Jequié', 'Teixeira de Freitas',
        'Barreiras', 'Alagoinhas', 'Porto Seguro', 'Simões Filho', 'Paulo Afonso',
        'Eunápolis', 'Santo Antônio de Jesus', 'Valença', 'Candeias', 'Guanambi', 'Jacobina',
        'Serra Dourada', 'Dias d\'Ávila', 'Luís Eduardo Magalhães'
      ],
      // Rio Grande do Sul (RS)
      43: [
        'Porto Alegre', 'Caxias do Sul', 'Pelotas', 'Canoas', 'Santa Maria',
        'Gravataí', 'Viamão', 'Novo Hamburgo', 'São Leopoldo', 'Rio Grande',
        'Alvorada', 'Passo Fundo', 'Sapucaia do Sul', 'Uruguaiana', 'Santa Cruz do Sul',
        'Cachoeirinha', 'Bagé', 'Bento Gonçalves', 'Erechim', 'Guaíba', 'Cachoeira do Sul'
      ],
      // Paraná (PR)
      41: [
        'Curitiba', 'Londrina', 'Maringá', 'Ponta Grossa', 'Cascavel',
        'São José dos Pinhais', 'Foz do Iguaçu', 'Colombo', 'Guarapuava', 'Paranaguá',
        'Apucarana', 'Toledo', 'Araucária', 'Campo Largo', 'Pinhais', 'Umuarama', 'Cambé'
      ],
      // Santa Catarina (SC)
      42: [
        'Florianópolis', 'Joinville', 'Blumenau', 'São José', 'Chapecó',
        'Itajaí', 'Criciúma', 'Jaraguá do Sul', 'Palhoça', 'Lages', 'Balneário Camboriú',
        'Brusque', 'Tubarão', 'São Bento do Sul', 'Rio do Sul'
      ],
      // Distrito Federal (DF)
      53: [
        'Brasília', 'Ceilândia', 'Taguatinga', 'Samambaia', 'Plano Piloto',
        'Gama', 'Recanto das Emas', 'Águas Claras', 'Guará', 'Santa Maria'
      ],
      // Otros estados (puedes agregar más municipios después)
    };
  }
}
