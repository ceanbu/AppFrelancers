import 'package:flutter/material.dart';
import 'package:jobbit/screens/register_employer_screen.dart';
import 'package:jobbit/screens/register_freelancer_screen.dart'; // Asegúrate que esta línea esté

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escolha seu Perfil'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 4.0, // Sombra sutil para o AppBar
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.purple.shade200],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Título o mensaje de bienvenida
                Text(
                  'Como você quer usar o WorkFlex?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                // Botón Freelancer
                ElevatedButton.icon(
                  icon: const Icon(Icons.person_search, size: 28, color: Colors.white),
                  label: const Text(
                    'Sou Freelancer',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrangeAccent,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5.0, // Sombra para el botón
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterFreelancerScreen()),
                    );
                  },
                ),
                const SizedBox(height: 30),

                // Botón Empleador
                ElevatedButton.icon(
                  icon: const Icon(Icons.business_center, size: 28, color: Colors.white),
                  label: const Text(
                    'Sou Empregador',
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 5.0, // Sombra para el botón
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RegisterEmployerScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
