import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:workflex/core/widgets/wf_button.dart';
import 'package:workflex/core/widgets/wf_text_field.dart';
import 'package:workflex/core/constants/app_colors.dart';
import 'package:workflex/core/constants/app_text_styles.dart';
import 'package:workflex/features/onboarding_employer/presentation/widgets/wf_address_ibge.dart';

class EmployerRegisterScreen extends StatefulWidget {
  const EmployerRegisterScreen({super.key});

  @override
  State<EmployerRegisterScreen> createState() => _EmployerRegisterScreenState();
}

class _EmployerRegisterScreenState extends State<EmployerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _businessNameController = TextEditingController();
  String? _businessType;
  String? _repDocumentType;
  final _repDocumentNumberController = TextEditingController();
  DateTime? _repBirthDate;
  final _repPhoneController = TextEditingController();
  Map<String, String> _address = {};
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  bool get _isRepAgeValid {
    if (_repBirthDate == null) return false;
    final today = DateTime.now();
    int age = today.year - _repBirthDate!.year;
    if (today.month < _repBirthDate!.month ||
        (today.month == _repBirthDate!.month && today.day < _repBirthDate!.day)) {
      age--;
    }
    return age >= 18;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _businessNameController.dispose();
    _repDocumentNumberController.dispose();
    _repPhoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_isRepAgeValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El representante debe ser mayor de 18 aÃ±os')),
      );
      return;
    }
    if (_address['state'] == null || _address['state']!.isEmpty ||
        _address['municipality'] == null || _address['municipality']!.isEmpty ||
        _address['number'] == null || _address['number']!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa los campos obligatorios de direcciÃ³n: Estado, Municipio y NÃºmero')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final auth = FirebaseAuth.instance;
      final userCredential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      final uid = userCredential.user!.uid;

      final employerData = {
        'email': _emailController.text.trim(),
        'businessName': _businessNameController.text.trim(),
        'businessType': _businessType,
        'representativeInfo': {
          'docType': _repDocumentType,
          'docNumber': _repDocumentNumberController.text.trim(),
          'dob': _repBirthDate != null ? Timestamp.fromDate(_repBirthDate!) : null,
          'phone': _repPhoneController.text.trim(),
        },
        'address': _address,
        'credits': 0,
        'createdAt': FieldValue.serverTimestamp(),
      };
      await FirebaseFirestore.instance.collection('employers').doc(uid).set(employerData);

      if (mounted) {
        context.go('/employer/home');
      }
    } on FirebaseAuthException catch (e) {
      String mensaje;
      if (e.code == 'email-already-in-use') {
        mensaje = 'Este correo ya estÃ¡ en uso.';
      } else {
        mensaje = 'Error al registrar: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensaje)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error inesperado: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Registro Empleador'),
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Text('Datos de la cuenta', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 16),
                WFTextField(
                  controller: _emailController,
                  label: 'Email *',
                  hint: 'empresa@ejemplo.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Ingrese el email';
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Email no vÃ¡lido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                WFTextField(
                  controller: _passwordController,
                  label: 'ContraseÃ±a *',
                  hint: 'MÃ­nimo 6 caracteres',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (value) => value == null || value.length < 6 ? 'MÃ­nimo 6 caracteres' : null,
                ),
                const SizedBox(height: 16),
                WFTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirmar contraseÃ±a *',
                  hint: 'Repite la contraseÃ±a',
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Confirme la contraseÃ±a';
                    if (value != _passwordController.text) return 'Las contraseÃ±as no coinciden';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Text('Datos del negocio', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 16),
                WFTextField(
                  controller: _businessNameController,
                  label: 'Nombre del negocio *',
                  hint: 'Ej: Restaurante El SazÃ³n',
                  validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _businessType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de local *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'gastronomia', child: Text('GastronomÃ­a')),
                    DropdownMenuItem(value: 'comercio', child: Text('Comercio')),
                    DropdownMenuItem(value: 'otro', child: Text('Otro')),
                  ],
                  onChanged: (value) => setState(() => _businessType = value),
                  validator: (value) => value == null ? 'Seleccione un tipo' : null,
                ),
                const SizedBox(height: 24),
                Text('Representante legal', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _repDocumentType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de documento *',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'CPF', child: Text('CPF')),
                    DropdownMenuItem(value: 'CNPJ', child: Text('CNPJ')),
                    DropdownMenuItem(value: 'RG', child: Text('RG')),
                  ],
                  onChanged: (value) => setState(() => _repDocumentType = value),
                  validator: (value) => value == null ? 'Seleccione un tipo' : null,
                ),
                const SizedBox(height: 16),
                WFTextField(
                  controller: _repDocumentNumberController,
                  label: 'NÃºmero de documento *',
                  hint: 'Ej: 12345678900',
                  validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime(1980, 1, 1),
                      firstDate: DateTime(1950),
                      lastDate: DateTime.now(),
                      locale: const Locale('es', 'ES'),
                    );
                    if (picked != null) setState(() => _repBirthDate = picked);
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
                        text: _repBirthDate != null ? DateFormat('dd/MM/yyyy').format(_repBirthDate!) : '',
                      ),
                      validator: (value) {
                        if (_repBirthDate == null) return 'Seleccione la fecha';
                        if (!_isRepAgeValid) return 'Debe ser mayor de 18 aÃ±os';
                        return null;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                WFTextField(
                  controller: _repPhoneController,
                  label: 'TelÃ©fono (WhatsApp) *',
                  hint: 'Ej: 11999999999',
                  keyboardType: TextInputType.phone,
                  validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
                ),
                const SizedBox(height: 24),
                Text('DirecciÃ³n del negocio', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 8),
                WFAddressIBGE(
                  onAddressChanged: (addressMap) => _address = addressMap,
                ),
                const SizedBox(height: 32),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  WFButton(
                    label: 'Registrarse',
                    onPressed: _register,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}