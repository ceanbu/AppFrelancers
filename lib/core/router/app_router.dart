import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/onboarding_freelancer/presentation/screens/step1_personal_info_screen.dart';
import '../../features/onboarding_freelancer/presentation/screens/step2_availability_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/freelancer/step1',
    routes: [
      GoRoute(
        path: '/freelancer/step1',
        name: 'freelancer_step1',
        builder: (context, state) => const FreelancerStep1Screen(),
      ),
      GoRoute(
        path: '/freelancer/step2',
        name: 'freelancer_step2',
        builder: (context, state) => const Step2AvailabilityScreen(),
      ),
    ],
  );
});
