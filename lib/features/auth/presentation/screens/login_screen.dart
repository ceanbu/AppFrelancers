import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workflex/core/constants/app_colors.dart';
import 'package:workflex/core/constants/app_text_styles.dart';
import 'package:workflex/core/widgets/wf_button.dart';
import 'package:workflex/core/widgets/wf_text_field.dart';
import 'package:workflex/core/utils/validators.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _rememberSession = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final auth = FirebaseAuth.instance;
      final userCredential = await auth.signInWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );
      final uid = userCredential.user!.uid;

      final freelancerDoc = await FirebaseFirestore.instance
          .collection('freelancers')
          .doc(uid)
          .get();
      if (freelancerDoc.exists) {
        if (mounted) context.go('/freelancer/jobs');
        return;
      }

      final employerDoc = await FirebaseFirestore.instance
          .collection('employers')
          .doc(uid)
          .get();
      if (employerDoc.exists) {
        if (mounted) context.go('/employer/home');
        return;
      }

      if (mounted) {
        setState(() => _errorMessage = 'Usuario sin perfil completo.');
      }
    } on FirebaseAuthException catch (e) {
      String mensaje;
      switch (e.code) {
        case 'user-not-found':
          mensaje = 'No existe una cuenta con ese email.';
          break;
        case 'wrong-password':
          mensaje = 'Contraseña incorrecta.';
          break;
        case 'invalid-email':
          mensaje = 'El email no es válido.';
          break;
        default:
          mensaje = 'Error al iniciar sesión. Intenta nuevamente.';
      }
      setState(() => _errorMessage = mensaje);
    } catch (e) {
      setState(() => _errorMessage = 'Error inesperado: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),
                Text('Bienvenido de nuevo', style: AppTextStyles.displayMedium),
                const SizedBox(height: 8),
                Text(
                  'Iniciá sesión para continuar',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                WFTextField(
                  hint: 'tu@email.com',
                  label: 'Email',
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.validateEmail,
                ),
                const SizedBox(height: 16),

                WFTextField(
                  hint: 'Mínimo 6 caracteres',
                  label: 'Contraseña',
                  controller: _passwordCtrl,
                  obscureText: true,
                  validator: AppValidators.validatePassword,
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Checkbox(
                      value: _rememberSession,
                      onChanged: (v) =>
                          setState(() => _rememberSession = v ?? false),
                      activeColor: AppColors.primary,
                    ),
                    Text(
                      'Recordar sesión',
                      style: AppTextStyles.bodyMedium,
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        '¿Olvidaste tu contraseña?',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  WFButton(
                    label: 'Iniciar Sesión',
                    onPressed: _login,
                  ),
                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tenés cuenta? ',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => context.go('/'),
                      child: Text(
                        'Registrate',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
