import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:workflex/core/widgets/wf_address_ibge.dart';
import 'package:workflex/core/constants/app_colors.dart';
import 'package:workflex/core/constants/app_text_styles.dart';

class EditAddressScreen extends StatefulWidget {
  final Map<String, String> currentAddress;
  const EditAddressScreen({super.key, required this.currentAddress});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  late Map<String, String> _address;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _address = Map<String, String>.from(widget.currentAddress);
  }

  bool get _isValid =>
      (_address['state'] ?? '').isNotEmpty &&
      (_address['municipality'] ?? '').isNotEmpty &&
      (_address['number'] ?? '').isNotEmpty;

  Future<void> _save() async {
    if (!_isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completá Estado, Municipio y Número antes de guardar'),
        ),
      );
      return;
    }
    setState(() => _isSaving = true);
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      await FirebaseFirestore.instance.collection('freelancers').doc(uid).update({
        'address': _address,
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Editar dirección', style: AppTextStyles.headlineMedium),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context, false),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // initialAddress precarga estado/municipio/campos de texto —
            // requiere el WFAddressIBGE actualizado con soporte para edición.
            WFAddressIBGE(
              initialAddress: _address,
              onAddressChanged: (newAddress) => _address = newAddress,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Guardar cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
