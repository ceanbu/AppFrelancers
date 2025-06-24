import 'package:flutter/material.dart';
import 'package:jobbit/models/estado.dart';
import 'package:jobbit/models/municipio.dart';
import 'package:jobbit/services/ibge_service.dart';
// import 'package:jobbit/models/freelancer.dart'; // Descomentar cuando se use Freelancer

class RegisterFreelancerScreen extends StatefulWidget {
  const RegisterFreelancerScreen({super.key});

  @override
  State<RegisterFreelancerScreen> createState() => _RegisterFreelancerScreenState();
}

class _RegisterFreelancerScreenState extends State<RegisterFreelancerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ibgeService = IbgeService();

  // Controllers para los campos del formulario
  final _fullNameController = TextEditingController();
  final _documentNumberController = TextEditingController(); // Para el número de documento
  final _dateOfBirthController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();

  List<Estado> _estados = [];
  List<Municipio> _municipios = [];
  Estado? _selectedEstado;
  Municipio? _selectedMunicipio;
  DateTime? _selectedDate;
  String? _selectedDocumentType; // Para el tipo de documento seleccionado
  final List<String> _documentTypes = ['CPF', 'RG', 'RNM', 'CRNM']; // Tipos de documento

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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateOfBirthController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _registerFreelancer() {
    if (_formKey.currentState!.validate()) {
      if (_selectedEstado == null || _selectedMunicipio == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione estado e município.')),
        );
        return;
      }
      // La validación de _selectedDate y _selectedDocumentType ya está en los validadores de los campos

      // Aquí crearías el objeto Freelancer y lo enviarías a un backend
      // final freelancer = Freelancer(
      //   fullName: _fullNameController.text,
      //   documentType: _selectedDocumentType!,
      //   documentNumber: _documentNumberController.text,
      //   dateOfBirth: _selectedDate!,
      //   phone: _phoneController.text,
      //   email: _emailController.text,
      //   password: _passwordController.text,
      //   stateId: _selectedEstado!.sigla, 
      //   cityId: _selectedMunicipio!.id.toString(),
      //   neighborhood: _neighborhoodController.text,
      //   street: _streetController.text,
      //   number: _numberController.text,
      //   complement: _complementController.text,
      // );

      print('Registrando Freelancer:');
      print('Nome Completo: ${_fullNameController.text}');
      print('Tipo de Documento: $_selectedDocumentType');
      print('Número do Documento: ${_documentNumberController.text}');
      print('Data de Nascimento: ${_dateOfBirthController.text}');
      print('Telefone: ${_phoneController.text}');
      print('Email: ${_emailController.text}');
      print('Senha: ${_passwordController.text}');
      print('Estado: ${_selectedEstado?.nome}');
      print('Município: ${_selectedMunicipio?.nome}');
      print('Bairro: ${_neighborhoodController.text}');
      print('Logradouro: ${_streetController.text}');
      print('Número: ${_numberController.text}');
      print('Complemento: ${_complementController.text}');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro de Freelancer simulado com sucesso! (Verifique o console)')),
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _documentNumberController.dispose();
    _dateOfBirthController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _neighborhoodController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Freelancer'),
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
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Nome Completo'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome completo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Tipo de Documento'),
                value: _selectedDocumentType,
                hint: const Text('Selecione o tipo de documento'),
                isExpanded: true,
                items: _documentTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDocumentType = newValue;
                  });
                },
                validator: (value) => value == null ? 'Selecione o tipo de documento' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _documentNumberController,
                decoration: const InputDecoration(labelText: 'Número do Documento'),
                keyboardType: TextInputType.text, 
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o número do documento';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _dateOfBirthController,
                decoration: const InputDecoration(
                  labelText: 'Data de Nascimento',
                  hintText: 'DD/MM/AAAA',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, selecione a data de nascimento';
                  }
                  if (_selectedDate != null) {
                    final today = DateTime.now();
                    final age = today.year - _selectedDate!.year -
                                (today.month < _selectedDate!.month ||
                                (today.month == _selectedDate!.month && today.day < _selectedDate!.day) ? 1 : 0);
                    if (age < 18) {
                      return 'Você deve ter pelo menos 18 anos.';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Telefone (com DDD)',
                  helperText: 'Este telefone será usado para contato via WhatsApp.',
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o telefone';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o email';
                  }
                  if (!value.contains('@') || !value.contains('.')) {
                    return 'Por favor, insira um email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a senha';
                  }
                  if (value.length < 6) {
                    return 'Senha deve ter no mínimo 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirmar Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, confirme a senha';
                  }
                  if (value != _passwordController.text) {
                    return 'As senhas não coincidem';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text('Endereço', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_loadingEstados) const Center(child: CircularProgressIndicator()),
              if (_errorEstados != null) Center(child: Text(_errorEstados!, style: const TextStyle(color: Colors.red))),
              if (!_loadingEstados && _errorEstados == null)
                DropdownButtonFormField<Estado>(
                  decoration: const InputDecoration(labelText: 'Estado (UF)'),
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
                  decoration: const InputDecoration(labelText: 'Município'),
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
                decoration: const InputDecoration(labelText: 'Bairro'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o bairro';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _streetController,
                decoration: const InputDecoration(labelText: 'Logradouro (Rua, Av, etc.)'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o logradouro';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(labelText: 'Número'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o número';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _complementController,
                decoration: const InputDecoration(labelText: 'Complemento (Opcional)'),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _registerFreelancer,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text('Registrar como Freelancer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}