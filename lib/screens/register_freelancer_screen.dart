import 'package:flutter/material.dart';
import 'package:jobbit/models/estado.dart';
import 'package:jobbit/models/municipio.dart';
import 'package:jobbit/services/ibge_service.dart';
import 'package:jobbit/screens/freelancer_availability_screen.dart'; // Importar la nueva pantalla

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
        _dateOfBirthController.text = \"${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}\";
      });
    }
  }

  void _registerFreelancerAndContinue() { // Nombre de la función actualizado
    if (_formKey.currentState!.validate()) {
      if (_selectedEstado == null || _selectedMunicipio == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, selecione estado e município.')),\n        );\n        return;\n      }\n      // Las validaciones de _selectedDate y _selectedDocumentType están en los validadores de los campos.\n\n      // TODO: Aquí deberías guardar los datos del freelancer (usando el objeto Freelancer)\n      // si la validación es exitosa, antes de navegar.\n      // Por ejemplo, podrías llamar a una función de tu servicio de autenticación/backend.\n\n      print('Dados do Freelancer (para simulação):');\n      print('Nome Completo: ${_fullNameController.text}');\n      print('Tipo de Documento: $_selectedDocumentType');\n      print('Número do Documento: ${_documentNumberController.text}');\n      print('Data de Nascimento: ${_dateOfBirthController.text}');\n      print('Telefone: ${_phoneController.text}');\n      print('Email: ${_emailController.text}');\n      // No imprimimos la contraseña por seguridad, pero la tendrías en _passwordController.text\n      print('Estado: ${_selectedEstado?.nome}');\n      print('Município: ${_selectedMunicipio?.nome}');\n      print('Bairro: ${_neighborhoodController.text}');\n      print('Logradouro: ${_streetController.text}');\n      print('Número: ${_numberController.text}');\n      print('Complemento: ${_complementController.text}');\n\n      // Navegar a la pantalla de configuración de disponibilidad\n      Navigator.push(\n        context,\n        MaterialPageRoute(builder: (context) => const FreelancerAvailabilityScreen()),\n      );\n    }\n  }\n\n  @override\n  void dispose() {\n    _fullNameController.dispose();\n    _documentNumberController.dispose();\n    _dateOfBirthController.dispose();\n    _phoneController.dispose();\n    _emailController.dispose();\n    _passwordController.dispose();\n    _confirmPasswordController.dispose();\n    _neighborhoodController.dispose();\n    _streetController.dispose();\n    _numberController.dispose();\n    _complementController.dispose();\n    super.dispose();\n  }\n\n  @override\n  Widget build(BuildContext context) {\n    return Scaffold(\n      appBar: AppBar(\n        title: const Text('Cadastro de Freelancer'),\n        backgroundColor: Theme.of(context).colorScheme.inversePrimary,\n      ),\n      body: SingleChildScrollView(\n        padding: const EdgeInsets.all(16.0),\n        child: Form(\n          key: _formKey,\n          child: Column(\n            crossAxisAlignment: CrossAxisAlignment.stretch,\n            children: <Widget>[\n              TextFormField(\n                controller: _fullNameController,\n                decoration: const InputDecoration(labelText: 'Nome Completo'),\n                validator: (value) {\n                  if (value == null || value.isEmpty) {\n                    return 'Por favor, insira o nome completo';\n                  }\n                  return null;\n                },\n              ),\n              const SizedBox(height: 16),\n              DropdownButtonFormField<String>(\n                decoration: const InputDecoration(labelText: 'Tipo de Documento'),\n                value: _selectedDocumentType,\n                hint: const Text('Selecione o tipo de documento'),\n                isExpanded: true,\n                items: _documentTypes.map((String type) {\n                  return DropdownMenuItem<String>(\n                    value: type,\n                    child: Text(type),\n                  );\n                }).toList(),\n                onChanged: (String? newValue) {\n                  setState(() {\n                    _selectedDocumentType = newValue;\n                  });\n                },\n                validator: (value) => value == null ? 'Selecione o tipo de documento' : null,\n              ),\n              const SizedBox(height: 16),\n              TextFormField(\n                controller: _documentNumberController,\n                decoration: const InputDecoration(labelText: 'Número do Documento'),\n                keyboardType: TextInputType.text, \n                validator: (value) {\n                  if (value == null || value.isEmpty) {\n                    return 'Por favor, insira o número do documento';\n                  }\n                  return null;\n                },\n              ),\n              const SizedBox(height: 16),\n              TextFormField(\n                controller: _dateOfBirthController,\n                decoration: const InputDecoration(\n                  labelText: 'Data de Nascimento',\n                  hintText: 'DD/MM/AAAA',\n                  suffixIcon: Icon(Icons.calendar_today),\n                ),\n                readOnly: true,\n                onTap: () => _selectDate(context),\n                validator: (value) {\n                  if (value == null || value.isEmpty) {\n                    return 'Por favor, selecione a data de nascimento';\n                  }\n                  if (_selectedDate != null) {\n                    final today = DateTime.now();\n                    final age = today.year - _selectedDate!.year -\n                                (today.month < _selectedDate!.month ||\n                                (today.month == _selectedDate!.month && today.day < _selectedDate!.day) ? 1 : 0);\n                    if (age < 18) {\n                      return 'Você deve ter pelo menos 18 anos.';\n                    }\n                  }\n                  return null;\n                },\n              ),\n              const SizedBox(height: 16),\n              TextFormField(\n                controller: _phoneController,\n                decoration: const InputDecoration(\n                  labelText: 'Telefone (com DDD)',\n                  helperText: 'Este telefone será usado para contato via WhatsApp.',\n                ),\n                keyboardType: TextInputType.phone,\n                validator: (value) {\n                  if (value == null || value.isEmpty) {\n                    return 'Por favor, insira o telefone';\n                  }\n                  return null;\n                },\n              ),\n              const SizedBox(height: 16),\n              TextFormField(\n                controller: _emailController,\n                decoration: const InputDecoration(labelText: 'Email'),\n                keyboardType: TextInputType.emailAddress,\n                validator: (value) {\n                  if (value == null || value.isEmpty) {\n                    return 'Por favor, insira o email';\n                  }\n                  if (!value.contains('@') || !value.contains('.')) {\n                    return 'Por favor, insira um email válido';\n                  }\n                  return null;\n                },\n              ),\n              const SizedBox(height: 16),\n              TextFormField(\n                controller: _passwordController,\n                decoration: const InputDecoration(labelText: 'Senha'),\n                obscureText: true,\n                validator: (value) {\n                  if (value == null || value.isEmpty) {\n                    return 'Por favor, insira a senha';\n                  }\n                  if (value.length < 6) {\n                    return 'Senha deve ter no mínimo 6 caracteres';\n                  }\n                  return null;\n                },\n              ),\n              const SizedBox(height: 16),\n              TextFormField(\n                controller: _confirmPasswordController,\n                decoration: const InputDecoration(labelText: 'Confirmar Senha'),\n                obscureText: true,\n                validator: (value) {\n                  if (value == null || value.isEmpty) {\n                    return 'Por favor, confirme a senha';\n                  }\n                  if (value != _passwordController.text) {\n                    return 'As senhas não coincidem';\n                  }\n                  return null;\n                },\n              ),\n              const SizedBox(height: 24),\n              const Text('Endereço', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),\n              const SizedBox(height: 8),\n              if (_loadingEstados) const Center(child: CircularProgressIndicator()),\n              if (_errorEstados != null) Center(child: Text(_errorEstados!, style: const TextStyle(color: Colors.red))),\n              if (!_loadingEstados && _errorEstados == null)\n                DropdownButtonFormField<Estado>(\n                  decoration: const InputDecoration(labelText: 'Estado (UF)'),\n                  value: _selectedEstado,\n                  hint: const Text('Selecione o Estado'),\n                  isExpanded: true,\n                  items: _estados.map((Estado estado) {\n                    return DropdownMenuItem<Estado>(\n                      value: estado,\n                      child: Text(estado.nome),\n                    );\n                  }).toList(),\n                  onChanged: (Estado? newValue) {\n                    setState(() {\n                      _selectedEstado = newValue;\n                      _selectedMunicipio = null; \n                      _municipios = []; \n                      if (newValue != null) {\n                        _loadMunicipios(newValue.id.toString());\n                      }\n                    });\n                  },\n                  validator: (value) => value == null ? 'Selecione um estado' : null,\n                ),\n              const SizedBox(height: 16),\n              if (_loadingMunicipios) const Center(child: CircularProgressIndicator()),\n              if (_errorMunicipios != null) Center(child: Text(_errorMunicipios!, style: const TextStyle(color: Colors.red))),\n              if (!_loadingMunicipios && _errorMunicipios == null && _selectedEstado != null)\n                DropdownButtonFormField<Municipio>(\n                  decoration: const InputDecoration(labelText: 'Município'),\n                  value: _selectedMunicipio,\n                  hint: const Text('Selecione o Município'),\n                  isExpanded: true,\n                  items: _municipios.map((Municipio municipio) {\n                    return DropdownMenuItem<Municipio>(\n                      value: municipio,\n                      child: Text(municipio.nome),\n                    );\n                  }).toList(),\n                  onChanged: (Municipio? newValue) {\n                    setState(() {\n                      _selectedMunicipio = newValue;\n                    });\n                  },\n                  validator: (value) => value == null ? 'Selecione um município' : null,\n                ),\n              const SizedBox(height: 16),\n              TextFormField(\n                controller: _neighborhoodController,\n                decoration: const InputDecoration(labelText: 'Bairro'),\n                validator: (value) {\n                  if (value == null || value.isEmpty) {\n                    return 'Por favor, insira o bairro';\n                  }\n                  return null;\n                },\n              ),\n              const SizedBox(height: 16),\n              TextFormField(\n                controller: _streetController,\n                decoration: const InputDecoration(labelText: 'Logradouro (Rua, Av, etc.)'),\n                validator: (value) {\n                  if (value == null || value.isEmpty) {\n                    return 'Por favor, insira o logradouro';\n                  }\n                  return null;\n                },\n              ),\n              const SizedBox(height: 16),\n              TextFormField(\n                controller: _numberController,\n                decoration: const InputDecoration(labelText: 'Número'),\n                keyboardType: TextInputType.number,\n                validator: (value) {\n                  if (value == null || value.isEmpty) {\n                    return 'Por favor, insira o número';\n                  }\n                  return null;\n                },\n              ),\n              const SizedBox(height: 16),\n              TextFormField(\n                controller: _complementController,\n                decoration: const InputDecoration(labelText: 'Complemento (Opcional)'),\n              ),\n              const SizedBox(height: 32),\n              ElevatedButton(\n                onPressed: _registerFreelancerAndContinue, // Nombre de la función actualizado\n                style: ElevatedButton.styleFrom(\n                  padding: const EdgeInsets.symmetric(vertical: 16),\n                  backgroundColor: const Color(0xFF0A78ED), // Nuevo color aplicado\n                  foregroundColor: Colors.white, // Para que el texto del botón sea blanco\n                ),\n                child: const Text('Continuar'), // Texto del botón actualizado\n              ),\n            ],\n          ),\n        ),\n      ),\n    );\n  }\n}\n\n
