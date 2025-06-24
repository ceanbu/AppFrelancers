import 'package:flutter/material.dart';
import 'package:jobbit/models/estado.dart';
import 'package:jobbit/models/municipio.dart';
import 'package:jobbit/services/ibge_service.dart';

class RegisterEmployerScreen extends StatefulWidget {
  const RegisterEmployerScreen({super.key});

  @override
  State<RegisterEmployerScreen> createState() => _RegisterEmployerScreenState();
}

class _RegisterEmployerScreenState extends State<RegisterEmployerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ibgeService = IbgeService();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _representativeDocNumController = TextEditingController(); // Para el número de documento del representante
  final _representativeDobController = TextEditingController(); // Fecha de Nacimiento del Representante
  final _representativePhoneController = TextEditingController(); // Teléfono del representante
  final _neighborhoodController = TextEditingController();
  final _addressController = TextEditingController(); // Calle, Av etc.
  final _numberController = TextEditingController(); // Número del endereço
  final _complementController = TextEditingController(); // Complemento do endereço

  // Tipos de negocio (ejemplo)
  final List<String> _businessTypes = ['Restaurante', 'Loja', 'Bar', 'Cafeteria', 'Outro'];
  String? _selectedBusinessType;

  // Estados e Municípios
  List<Estado> _estados = [];
  List<Municipio> _municipios = [];
  Estado? _selectedEstado;
  Municipio? _selectedMunicipio;
  DateTime? _selectedRepresentativeDate; // Para la fecha de nacimiento del representante

  // Tipos de documento para el representante
  String? _selectedRepresentativeDocType;
  final List<String> _representativeDocumentTypes = ['CPF', 'CNPJ', 'RG', 'RNM', 'CRNM'];

  bool _loadingEstados = false;
  bool _loadingMunicipios = false;
  String? _errorEstados;
  String? _errorMunicipios;

  @override
  void initState() {
    super.initState();
    _loadEstados();
  }

  Future<void> _loadEstados() async {
    setState(() {
      _loadingEstados = true;
      _errorEstados = null;
      _selectedEstado = null;
      _municipios = [];
      _selectedMunicipio = null;
    });
    try {
      final estados = await _ibgeService.getEstados();
      setState(() {
        _estados = estados;
        _loadingEstados = false;
      });
    } catch (e) {
      setState(() {
        _errorEstados = "Erro ao carregar estados: ${e.toString()}";
        _loadingEstados = false;
      });
    }
  }

  Future<void> _loadMunicipios(String estadoId) async {
    setState(() {
      _loadingMunicipios = true;
      _errorMunicipios = null;
      _municipios = [];
      _selectedMunicipio = null;
    });
    try {
      final municipios = await _ibgeService.getMunicipiosPorEstado(estadoId);
      setState(() {
        _municipios = municipios;
        _loadingMunicipios = false;
      });
    } catch (e) {
      setState(() {
        _errorMunicipios = "Erro ao carregar municípios: ${e.toString()}";
        _loadingMunicipios = false;
      });
    }
  }

  Future<void> _selectRepresentativeDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedRepresentativeDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedRepresentativeDate) {
      setState(() {
        _selectedRepresentativeDate = picked;
        _representativeDobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _registerEmployer() {
    if (_formKey.currentState!.validate()) {
      // Validaciones adicionales ya están en los validadores de los campos
      // (estado, municipio, tipo de negocio, tipo de doc rep, fecha nac rep)
      
      print('Registrando Negócio:');
      print('Email: ${_emailController.text}');
      print('Senha: ${_passwordController.text}');
      print('Nome do Negócio: ${_businessNameController.text}');
      print('Tipo de Documento do Representante: $_selectedRepresentativeDocType');
      print('Número do Documento do Representante: ${_representativeDocNumController.text}');
      print('Data de Nascimento do Representante: ${_representativeDobController.text}');
      print('Telefone do Representante: ${_representativePhoneController.text}');
      print('Tipo de Negócio: $_selectedBusinessType');
      print('Estado: ${_selectedEstado?.nome}');
      print('Município: ${_selectedMunicipio?.nome}');
      print('Bairro: ${_neighborhoodController.text}');
      print('Logradouro (Endereço): ${_addressController.text}');
      print('Número (Endereço): ${_numberController.text}');
      print('Complemento (Endereço): ${_complementController.text}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro de Negócio simulado com sucesso! (Verifique o console)')),
      );
      // TODO: Implementar lógica de registro real (API call, etc.)
      // Navigator.pop(context); // O navegar a otra pantalla
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _representativeDocNumController.dispose();
    _representativeDobController.dispose();
    _representativePhoneController.dispose();
    _neighborhoodController.dispose();
    _addressController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Negócio'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email do Negócio'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor, insira o email do negócio';
                  if (!value.contains('@') || !value.contains('.')) return 'Email inválido';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor, insira a senha';
                  if (value.length < 6) return 'Senha deve ter no mínimo 6 caracteres';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirmar Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Por favor, confirme a senha';
                  if (value != _passwordController.text) return 'As senhas não coincidem';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _businessNameController,
                decoration: const InputDecoration(labelText: 'Nome do Negócio'),
                validator: (value) => value == null || value.isEmpty ? 'Insira o nome do negócio' : null,
              ),
              const SizedBox(height: 24),
              const Text('Dados do Representante Legal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tipo de Documento do Representante'),
                value: _selectedRepresentativeDocType,
                hint: const Text('Selecione o tipo de documento'),
                isExpanded: true,
                items: _representativeDocumentTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedRepresentativeDocType = newValue;
                  });
                },
                validator: (value) => value == null ? 'Selecione o tipo de documento do representante' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _representativeDocNumController,
                decoration: const InputDecoration(labelText: 'Número do Documento do Representante'),
                keyboardType: TextInputType.text,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o número do documento do representante';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _representativeDobController,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento do Representante',
                  hintText: 'DD/MM/AAAA',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectRepresentativeDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione a data de nascimento do representante';
                  }
                  if (_selectedRepresentativeDate != null) {
                    final today = DateTime.now();
                    final age = today.year - _selectedRepresentativeDate!.year -
                                (today.month < _selectedRepresentativeDate!.month ||
                                (today.month == _selectedRepresentativeDate!.month && today.day < _selectedRepresentativeDate!.day) ? 1 : 0);
                    if (age < 18) {
                      return 'O representante deve ter pelo menos 18 anos.';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _representativePhoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone do Representante (com DDD)',
                  helperText: 'Este telefone será usado para contato via WhatsApp.',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o telefone do representante';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text('Dados do Negócio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tipo de Negócio'),
                value: _selectedBusinessType,
                hint: const Text('Selecione o tipo de negócio'),
                isExpanded: true,
                items: _businessTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBusinessType = newValue;
                  });
                },
                validator: (value) => value == null ? 'Selecione o tipo de negócio' : null,
              ),
              const SizedBox(height: 16),
              if (_loadingEstados) const Center(child: CircularProgressIndicator()),
              if (_errorEstados != null) Center(child: Text(_errorEstados!, style: const TextStyle(color: Colors.red))),
              if (!_loadingEstados && _errorEstados == null)
                DropdownButtonFormField<Estado>(
                  decoration: const InputDecoration(labelText: 'Estado (UF) do Negócio'),
                  value: _selectedEstado,
                  hint: const Text('Selecione o Estado'),
                  isExpanded: true,
                  items: _estados.map((Estado estado) {
                    return DropdownMenuItem<Estado>(
                      value: estado,
                      child: Text(estado.nome),
                    );
                  }).toList(),
                  onChanged: (Estado? newValue) {
                    setState(() {
                      _selectedEstado = newValue;
                      _selectedMunicipio = null;
                      _municipios = [];
                      if (newValue != null) {
                        _loadMunicipios(newValue.id.toString());
                      }
                    });
                  },
                  validator: (value) => value == null ? 'Selecione um estado' : null,
                ),
              const SizedBox(height: 16),
              if (_loadingMunicipios) const Center(child: CircularProgressIndicator()),
              if (_errorMunicipios != null) Center(child: Text(_errorMunicipios!, style: const TextStyle(color: Colors.red))),
              if (!_loadingMunicipios && _errorMunicipios == null && _selectedEstado != null)
                DropdownButtonFormField<Municipio>(
                  decoration: const InputDecoration(labelText: 'Município do Negócio'),
                  value: _selectedMunicipio,
                  hint: const Text('Selecione o Município'),
                  isExpanded: true,
                  items: _municipios.map((Municipio municipio) {
                    return DropdownMenuItem<Municipio>(
                      value: municipio,
                      child: Text(municipio.nome),
                    );
                  }).toList(),
                  onChanged: (Municipio? newValue) {
                    setState(() {
                      _selectedMunicipio = newValue;
                    });
                  },
                  validator: (value) => value == null ? 'Selecione um município' : null,
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _neighborhoodController,
                decoration: const InputDecoration(labelText: 'Bairro do Negócio'),
                validator: (value) => value == null || value.isEmpty ? 'Insira o bairro' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Logradouro do Negócio (Rua, Av, etc.)'),
                validator: (value) => value == null || value.isEmpty ? 'Insira o logradouro' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(labelText: 'Número do Endereço do Negócio'),
                keyboardType: TextInputType.number,
                validator: (value) => value == null || value.isEmpty ? 'Insira o número' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _complementController,
                decoration: const InputDecoration(labelText: 'Complemento do Endereço (Opcional)'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _registerEmployer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text('Registrar Negócio'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}