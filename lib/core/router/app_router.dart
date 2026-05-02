import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/presentation/screens/role_selection_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

import '../../features/onboarding_freelancer/presentation/screens/step1_personal_info_screen.dart';
import '../../features/onboarding_freelancer/presentation/screens/step1b_about_me_screen.dart';
import '../../features/onboarding_freelancer/presentation/screens/step2_availability_screen.dart';
import '../../features/onboarding_freelancer/presentation/screens/step3_skills_screen.dart';
import '../../features/onboarding_freelancer/presentation/screens/step4_experience_screen.dart';

import '../../features/onboarding_employer/presentation/screens/employer_register_screen.dart';

import '../../features/employer_dashboard/presentation/screens/employer_home_screen.dart';
import '../../features/employer_dashboard/presentation/screens/create_vacancy_step1_screen.dart';
import '../../features/employer_dashboard/presentation/screens/create_vacancy_step2_screen.dart';
import '../../features/employer_dashboard/presentation/screens/vacancy_detail_screen.dart';
import '../../features/employer_dashboard/presentation/screens/applicants_screen.dart';

import '../../features/freelancer_jobs/presentation/screens/jobs_feed_screen.dart';
import '../../features/freelancer_jobs/presentation/screens/job_detail_screen.dart';
import '../../features/freelancer_jobs/presentation/screens/my_applications_screen.dart';

import '../../features/profile/presentation/screens/freelancer_profile_screen.dart';
import '../../features/profile/presentation/screens/employer_profile_screen.dart';

/// Rutas nombradas de la app
class AppRoutes {
  static const roleSelection = '/';
  static const login = '/login';

  // Onboarding Freelancer
  static const freelancerStep1 = '/freelancer/register/step1';
  static const freelancerAboutMe = '/freelancer/register/about-me';
  static const freelancerStep2 = '/freelancer/register/step2';
  static const freelancerStep3 = '/freelancer/register/step3';
  static const freelancerStep4 = '/freelancer/register/step4';

  // Onboarding Empleador
  static const employerRegister = '/employer/register';

  // Empleador
  static const employerHome = '/employer/home';
  static const createVacancyStep1 = '/employer/vacancy/create/step1';
  static const createVacancyStep2 = '/employer/vacancy/create/step2';
  static const vacancyDetail = '/employer/vacancy/:vacancyId';
  static const applicants = '/employer/vacancy/:vacancyId/applicants';

  // Freelancer
  static const jobsFeed = '/freelancer/jobs';
  static const jobDetail = '/freelancer/jobs/:jobId';
  static const myApplications = '/freelancer/applications';

  // Perfil
  static const freelancerProfile = '/freelancer/profile';
  static const employerProfile = '/employer/profile';
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.roleSelection,
    redirect: (context, state) {
      final isLoggedIn = authState.value != null;
      final isAuthRoute = state.matchedLocation == AppRoutes.roleSelection ||
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation.startsWith('/freelancer/register') ||
          state.matchedLocation == AppRoutes.employerRegister;

      // Si no está logueado y trata de acceder a ruta protegida
      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.roleSelection;
      }

      return null;
    },
    routes: [
      // ── Auth ──────────────────────────────────────
      GoRoute(
        path: AppRoutes.roleSelection,
        builder: (context, state) => const RoleSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // ── Onboarding Freelancer ─────────────────────
      GoRoute(
        path: AppRoutes.freelancerStep1,
        builder: (context, state) => const Step1PersonalInfoScreen(),
      ),
      GoRoute(
        path: AppRoutes.freelancerAboutMe,
        builder: (context, state) => const Step1bAboutMeScreen(),
      ),
      GoRoute(
        path: AppRoutes.freelancerStep2,
        builder: (context, state) => const Step2AvailabilityScreen(),
      ),
      GoRoute(
        path: AppRoutes.freelancerStep3,
        builder: (context, state) => const Step3SkillsScreen(),
      ),
      GoRoute(
        path: AppRoutes.freelancerStep4,
        builder: (context, state) => const Step4ExperienceScreen(),
      ),

      // ── Onboarding Empleador ──────────────────────
      GoRoute(
        path: AppRoutes.employerRegister,
        builder: (context, state) => const EmployerRegisterScreen(),
      ),

      // ── Empleador ─────────────────────────────────
      GoRoute(
        path: AppRoutes.employerHome,
        builder: (context, state) => const EmployerHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.createVacancyStep1,
        builder: (context, state) => const CreateVacancyStep1Screen(),
      ),
      GoRoute(
        path: AppRoutes.createVacancyStep2,
        builder: (context, state) => const CreateVacancyStep2Screen(),
      ),
      GoRoute(
        path: AppRoutes.vacancyDetail,
        builder: (context, state) {
          final vacancyId = state.pathParameters['vacancyId']!;
          return VacancyDetailScreen(vacancyId: vacancyId);
        },
      ),
      GoRoute(
        path: AppRoutes.applicants,
        builder: (context, state) {
          final vacancyId = state.pathParameters['vacancyId']!;
          return ApplicantsScreen(vacancyId: vacancyId);
        },
      ),

      // ── Freelancer ────────────────────────────────
      GoRoute(
        path: AppRoutes.jobsFeed,
        builder: (context, state) => const JobsFeedScreen(),
      ),
      GoRoute(
        path: AppRoutes.jobDetail,
        builder: (context, state) {
          final jobId = state.pathParameters['jobId']!;
          return JobDetailScreen(jobId: jobId);
        },
      ),
      GoRoute(
        path: AppRoutes.myApplications,
        builder: (context, state) => const MyApplicationsScreen(),
      ),

      // ── Perfil ────────────────────────────────────
      GoRoute(
        path: AppRoutes.freelancerProfile,
        builder: (context, state) => const FreelancerProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.employerProfile,
        builder: (context, state) => const EmployerProfileScreen(),
      ),
    ],
  );
});
