import 'package:flutter/material.dart';

// TODO: Import registration screens when they are created
// import 'package:jobbit/screens/register_freelancer_screen.dart';
// import 'package:jobbit/screens/register_employer_screen.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _navigateToFreelancerRegistration(BuildContext context) {
    // TODO: Navigate to Freelancer Registration Screen (A2)
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterFreelancerScreen()));
    print('Navigate to Freelancer Registration');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Freelancer Registration (Not Implemented Yet)')),
    );
  }

  void _navigateToEmployerRegistration(BuildContext context) {
    // TODO: Navigate to Employer Registration Screen (A6)
    // Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterEmployerScreen()));
    print('Navigate to Employer Registration');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navigate to Employer Registration (Not Implemented Yet)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Your Role'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Matching the HTML mockup provided earlier
                Text(
                  'WorkFlex',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28, // From HTML h2
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0C151D), // From HTML text-[#0c151d]
                  ),
                ),
                const SizedBox(height: 8), // Approximate spacing from HTML (pb-3 pt-1)
                Text(
                  'Connecting temporary jobs in gastronomy and retail.', // From HTML p
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16, // From HTML text-base
                    color: const Color(0xFF0C151D),
                  ),
                ),
                const SizedBox(height: 40), // More spacing before buttons

                // Button "I'm a Freelancer"
                // Based on RF1.1 and HTML mockup
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF359DFF), // From HTML bg-[#359dff]
                    padding: const EdgeInsets.symmetric(vertical: 12), // h-12
                    textStyle: const TextStyle(
                      fontSize: 16, // text-base
                      fontWeight: FontWeight.bold, // font-bold
                      letterSpacing: 0.015 * 16, // tracking-[0.015em]
                    ),
                  ),
                  onPressed: () => _navigateToFreelancerRegistration(context),
                  child: Text(
                    "I'm a Freelancer",
                    style: TextStyle(color: const Color(0xFF0C151D)), // From HTML text-[#0c151d]
                  ),
                ),
                const SizedBox(height: 12), // Spacing from HTML gap-3 (flex gap-3)

                // Button "I'm an Employer"
                // Based on RF1.1 and HTML mockup
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE6EDF4), // From HTML bg-[#e6edf4]
                    padding: const EdgeInsets.symmetric(vertical: 12), // h-12
                     textStyle: const TextStyle(
                      fontSize: 16, // text-base
                      fontWeight: FontWeight.bold, // font-bold
                      letterSpacing: 0.015 * 16, // tracking-[0.015em]
                    ),
                  ),
                  onPressed: () => _navigateToEmployerRegistration(context),
                  child: Text(
                    "I'm an Employer",
                    style: TextStyle(color: const Color(0xFF0C151D)), // From HTML text-[#0c151d]
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
