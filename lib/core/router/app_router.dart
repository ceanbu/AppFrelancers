import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:workflex/features/onboarding_freelancer/presentation/screens/step1_personal_info_screen.dart';
import 'package:workflex/features/onboarding_freelancer/presentation/screens/step2_availability_screen.dart';
import 'package:workflex/features/onboarding_freelancer/presentation/screens/step3_skills_screen.dart';
import 'package:workflex/features/onboarding_freelancer/presentation/screens/step4_experience_screen.dart';
import 'package:workflex/features/freelancer_jobs/presentation/screens/jobs_feed_screen.dart';
import 'package:workflex/features/freelancer_jobs/presentation/screens/job_detail_screen.dart';
import 'package:workflex/features/profile/presentation/screens/freelancer_profile_screen.dart';
import 'package:workflex/features/onboarding_employer/presentation/screens/employer_register_screen.dart';
import 'package:workflex/features/employer_dashboard/presentation/screens/employer_home_screen.dart';
import 'package:workflex/features/employer_dashboard/presentation/screens/create_vacancy_step1_screen.dart';
import 'package:workflex/features/employer_dashboard/presentation/screens/create_vacancy_step2_screen.dart';
import 'package:workflex/features/employer_dashboard/presentation/screens/vacancy_detail_screen.dart';
import 'package:workflex/features/employer_dashboard/presentation/screens/applicants_screen.dart';
import 'package:workflex/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:workflex/features/auth/presentation/screens/login_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final loc = state.matchedLocation;
      final isPublic = loc == '/' || loc == '/login' ||
          loc.startsWith('/freelancer/register') ||
          loc == '/employer/register';

      if (user != null && (loc == '/' || loc == '/login')) {
        final prefs = await SharedPreferences.getInstance();
        final rememberSession = prefs.getBool('remember_session') ?? false;
        if (rememberSession) {
          final role = prefs.getString('user_role');
          if (role == 'freelancer') return '/freelancer/jobs';
          if (role == 'employer') return '/employer/home';
        }
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', name: 'role_selection',
          builder: (context, state) => const RoleSelectionScreen()),
      GoRoute(path: '/login', name: 'login',
          builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/freelancer/register/step1', name: 'freelancer_step1',
          builder: (context, state) => const FreelancerStep1Screen()),
      GoRoute(path: '/freelancer/register/step2', name: 'freelancer_step2',
          builder: (context, state) => const Step2AvailabilityScreen()),
      GoRoute(path: '/freelancer/register/step3', name: 'freelancer_step3',
          builder: (context, state) => const Step3SkillsScreen()),
      GoRoute(path: '/freelancer/register/step4', name: 'freelancer_step4',
          builder: (context, state) => const Step4ExperienceScreen()),
      GoRoute(path: '/freelancer/jobs', name: 'freelancer_jobs',
          builder: (context, state) => const JobsFeedScreen()),
      GoRoute(path: '/freelancer/jobs/:jobId', name: 'job_detail',
          builder: (context, state) => JobDetailScreen(jobId: state.pathParameters['jobId']!)),
      GoRoute(path: '/freelancer/profile', name: 'freelancer_profile',
          builder: (context, state) => const FreelancerProfileScreen()),
      GoRoute(path: '/employer/register', name: 'employer_register',
          builder: (context, state) => const EmployerRegisterScreen()),
      GoRoute(path: '/employer/home', name: 'employer_home',
          builder: (context, state) => const EmployerHomeScreen()),
      GoRoute(path: '/employer/vacancy/create/step1', name: 'create_vacancy_step1',
          builder: (context, state) => const CreateVacancyStep1Screen()),
      GoRoute(path: '/employer/vacancy/create/step2', name: 'create_vacancy_step2',
          builder: (context, state) => const CreateVacancyStep2Screen()),
      GoRoute(path: '/employer/vacancy/:vacancyId', name: 'vacancy_detail',
          builder: (context, state) => VacancyDetailScreen(
              vacancyId: state.pathParameters['vacancyId']!)),
      GoRoute(path: '/employer/vacancy/:vacancyId/applicants', name: 'applicants_list',
          builder: (context, state) => ApplicantsListScreen(
              vacancyId: state.pathParameters['vacancyId']!)),
    ],
  );
});