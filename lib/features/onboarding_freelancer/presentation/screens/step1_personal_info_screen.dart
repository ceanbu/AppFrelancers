import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/wf_button.dart';
import '../../../../core/widgets/wf_text_field.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../widgets/address_ibge_widget.dart';

class FreelancerStep1Screen extends ConsumerStatefulWidget {
  const FreelancerStep1Screen({super.key});

  @override
  ConsumerState<FreelancerStep1Screen> createState() => _FreelancerStep1ScreenState();
}

class _FreelancerStep1ScreenState extends ConsumerState<FreelancerStep1Screen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _documentNumberController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _aboutMeController = TextEditingController();

  String? _documentType;
  DateTime? _birthDate;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  Map<String, String> _address = {};
  bool _isLoading = false;

  bool get _isAgeValid {
    if (_birthDate == null) return false;
    final today = DateTime.now();
    int age = today.year - _birthDate!.year;
    if (today.month < _birthDate!.month ||
        (today.month == _birthDate!.month && today.day < _birthDate!.day)) {
      age--;
    }
    return age >= 18;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registro - Paso 1/4'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              WFTextField(
                controller: _fullNameController,
                label: 'Nombre completo *',
                hint: 'Ej: Juan Pérez',
                validator: (value) => value == null || value.isEmpty ? 'Ingrese su nombre completo' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _documentType,
                decoration: const InputDecoration(
                  labelText: 'Tipo de documento *',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'CPF', child: Text('CPF')),
                  DropdownMenuItem(value: 'RG', child: Text('RG')),
                  DropdownMenuItem(value: 'RNM', child: Text('RNM')),
                  DropdownMenuItem(value: 'CRNM', child: Text('CRNM')),
                ],
                onChanged: (value) => setState(() => _documentType = value),
                validator: (value) => value == null ? 'Seleccione un tipo' : null,
              ),
              const SizedBox(height: 16),

              WFTextField(
                controller: _documentNumberController,
                label: 'Número de documento *',
                hint: 'Ej: 12345678900',
                validator: (value) => value == null || value.isEmpty ? 'Ingrese el número de documento' : null,
              ),
              const SizedBox(height: 16),

              GestureDetector(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000, 1, 1),
                    firstDate: DateTime(1950),
                    lastDate: DateTime.now(),
                    locale: const Locale('pt', 'BR'),
                  );
                  if (picked != null) setState(() => _birthDate = picked);
                },
                child: AbsorbPointer(
                  child: TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Fecha de nacimiento *',
                      hintText: 'DD/MM/AAAA',
                      suffixIcon: Icon(Icons.calendar_today),
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: _birthDate != null ? DateFormat('dd/MM/yyyy').format(_birthDate!) : '',
                    ),
                    validator: (value) {
                      if (_birthDate == null) return 'Seleccione su fecha de nacimiento';
                      if (!_isAgeValid) return 'Debe ser mayor de 18 años';
                      return null;
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              WFTextField(
                controller: _phoneController,
                label: 'Teléfono con DDD *',
                hint: 'Ej: 11999999999',
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Ingrese su teléfono' : null,
              ),
              const SizedBox(height: 16),

              WFTextField(
                controller: _emailController,
                label: 'Email *',
                hint: 'tu@email.com',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingrese su email';
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Email no valido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              WFTextField(
                controller: _passwordController,
                label: 'Contraseña *',
                hint: 'Mínimo 6 caracteres',
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) => value == null || value.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 16),

              WFTextField(
                controller: _confirmPasswordController,
                label: 'Confirmar contraseña *',
                hint: 'Repite la contraseña',
                obscureText: _obscureConfirmPassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Confirme su contraseña';
                  if (value != _passwordController.text) return 'Las contraseñas no coinciden';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              WFTextField(
                controller: _aboutMeController,
                label: 'Sobre mí',
                hint: 'Cuéntanos algo de ti... (opcional)',
                maxLines: 3,
              ),
              const SizedBox(height: 24),

              const Text('Dirección', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              AddressIbgeWidget(
                onAddressChanged: (addressMap) => _address = addressMap,
              ),
              const SizedBox(height: 32),

              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                WFButton(
                  label: 'Siguiente',
                  onPressed: _submitForm,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isAgeValid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes tener al menos 18 años')),
        );
      }
      return;
    }
    if (_address['state'] == null || _address['state']!.isEmpty ||
        _address['municipality'] == null || _address['municipality']!.isEmpty ||
        _address['number'] == null || _address['number']!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Completa los campos obligatorios de dirección: Estado, Municipio y Número')),
        );
      }
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      await authService.registerFreelancer(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.trim(),
        documentType: _documentType!,
        documentNumber: _documentNumberController.text.trim(),
        birthDate: _birthDate!,
        phone: _phoneController.text.trim(),
        aboutMe: _aboutMeController.text.trim(),
        address: _address,
      );

      if (mounted) {
        Navigator.pushNamed(context, '/freelancer/step2');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      String mensaje = e.toString();
      if (mensaje.contains('email-already-in-use')) {
        mensaje = 'Este correo ya está en uso. Prueba con otro o inicia sesión.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(mensaje)),
        );
      }
    }
  }
}
