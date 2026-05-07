import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Pantallas existentes (freelancer)
import '../../features/onboarding_freelancer/presentation/screens/step1_personal_info_screen.dart';
import '../../features/onboarding_freelancer/presentation/screens/step2_availability_screen.dart';
import '../../features/onboarding_freelancer/presentation/screens/step3_skills_screen.dart';
import '../../features/onboarding_freelancer/presentation/screens/step4_experience_screen.dart';
import '../../features/freelancer_jobs/presentation/screens/jobs_feed_screen.dart';
import '../../features/freelancer_jobs/presentation/screens/job_detail_screen.dart';
import '../../features/profile/presentation/screens/freelancer_profile_screen.dart';

// Pantallas empleador
import '../../features/onboarding_employer/presentation/screens/employer_register_screen.dart';
import '../../features/employer_dashboard/presentation/screens/employer_home_screen.dart';
import '../../features/employer_dashboard/presentation/screens/create_vacancy_step1_screen.dart';
import '../../features/employer_dashboard/presentation/screens/create_vacancy_step2_screen.dart';
import '../../features/employer_dashboard/presentation/screens/vacancy_detail_screen.dart';
import '../../features/employer_dashboard/presentation/screens/applicants_screen.dart';

// Autenticación
import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'role_selection',
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/freelancer/register/step1',
        name: 'freelancer_step1',
        builder: (context, state) => const FreelancerStep1Screen(),
      ),
      GoRoute(
        path: '/freelancer/register/step2',
        name: 'freelancer_step2',
        builder: (context, state) => const Step2AvailabilityScreen(),
      ),
      GoRoute(
        path: '/freelancer/register/step3',
        name: 'freelancer_step3',
        builder: (context, state) => const Step3SkillsScreen(),
      ),
      GoRoute(
        path: '/freelancer/register/step4',
        name: 'freelancer_step4',
        builder: (context, state) => const Step4ExperienceScreen(),
      ),
      GoRoute(
        path: '/freelancer/jobs',
        name: 'freelancer_jobs',
        builder: (context, state) => const JobsFeedScreen(),
      ),
      GoRoute(
        path: '/freelancer/jobs/:jobId',
        name: 'job_detail',
        builder: (context, state) => JobDetailScreen(
          jobId: state.pathParameters['jobId']!,
        ),
      ),
      GoRoute(
        path: '/freelancer/profile',
        name: 'freelancer_profile',
        builder: (context, state) => const FreelancerProfileScreen(),
      ),
      GoRoute(
        path: '/employer/register',
        name: 'employer_register',
        builder: (context, state) => const EmployerRegisterScreen(),
      ),
      GoRoute(
        path: '/employer/home',
        name: 'employer_home',
        builder: (context, state) => const EmployerHomeScreen(),
      ),
      GoRoute(
        path: '/employer/vacancy/create/step1',
        name: 'create_vacancy_step1',
        builder: (context, state) => const CreateVacancyStep1Screen(),
      ),
      GoRoute(
        path: '/employer/vacancy/create/step2',
        name: 'create_vacancy_step2',
        builder: (context, state) => const CreateVacancyStep2Screen(),
      ),
      GoRoute(
        path: '/employer/vacancy/:vacancyId',
        name: 'vacancy_detail',
        builder: (context, state) => VacancyDetailScreen(
          vacancyId: state.pathParameters['vacancyId']!,
        ),
      ),
      GoRoute(
        path: '/employer/vacancy/:vacancyId/applicants',
        name: 'applicants_list',
        builder: (context, state) => ApplicantsListScreen(
          vacancyId: state.pathParameters['vacancyId']!,
        ),
      ),
    ],
  );
});