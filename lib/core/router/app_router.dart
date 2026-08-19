import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:workflex/core/widgets/freelancer_shell.dart';
import 'package:workflex/core/widgets/employer_shell.dart';

import 'package:workflex/features/onboarding_freelancer/presentation/screens/step1_personal_info_screen.dart';
import 'package:workflex/features/onboarding_freelancer/presentation/screens/step2_availability_screen.dart';
import 'package:workflex/features/onboarding_freelancer/presentation/screens/step3_skills_screen.dart';
import 'package:workflex/features/onboarding_freelancer/presentation/screens/step4_experience_screen.dart';
import 'package:workflex/features/freelancer_jobs/presentation/screens/jobs_feed_screen.dart';
import 'package:workflex/features/freelancer_jobs/presentation/screens/job_detail_screen.dart';
import 'package:workflex/features/freelancer_jobs/presentation/screens/my_applications_screen.dart';
import 'package:workflex/features/profile/presentation/screens/freelancer_profile_screen.dart';
import 'package:workflex/features/onboarding_employer/presentation/screens/employer_register_screen.dart';
import 'package:workflex/features/employer_dashboard/presentation/screens/employer_home_screen.dart';
import 'package:workflex/features/employer_dashboard/presentation/screens/employer_profile_screen.dart';
import 'package:workflex/features/employer_dashboard/presentation/screens/create_vacancy_step1_screen.dart';
import 'package:workflex/features/employer_dashboard/presentation/screens/create_vacancy_step2_screen.dart';
import 'package:workflex/features/employer_dashboard/presentation/screens/vacancy_detail_screen.dart';
import 'package:workflex/features/employer_dashboard/presentation/screens/applicants_screen.dart';
import 'package:workflex/features/employer_dashboard/presentation/screens/freelancer_preview_screen.dart';
import 'package:workflex/features/auth/presentation/screens/role_selection_screen.dart';
import 'package:workflex/features/auth/presentation/screens/login_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _freelancerShellKey = GlobalKey<NavigatorState>(debugLabel: 'freelancerShell');
final _employerShellKey = GlobalKey<NavigatorState>(debugLabel: 'employerShell');

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final loc = state.matchedLocation;

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
        path: '/employer/register',
        name: 'employer_register',
        builder: (context, state) => const EmployerRegisterScreen(),
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            FreelancerShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _freelancerShellKey,
            routes: [
              GoRoute(
                path: '/freelancer/jobs',
                name: 'freelancer_jobs',
                builder: (context, state) => const JobsFeedScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/freelancer/applications',
                name: 'freelancer_applications',
                builder: (context, state) => const MyApplicationsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/freelancer/profile',
                name: 'freelancer_profile',
                builder: (context, state) => const FreelancerProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            EmployerShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _employerShellKey,
            routes: [
              GoRoute(
                path: '/employer/home',
                name: 'employer_home',
                builder: (context, state) => const EmployerHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/employer/profile',
                name: 'employer_profile',
                builder: (context, state) => const EmployerProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      GoRoute(
        path: '/freelancer/jobs/:jobId',
        name: 'job_detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => JobDetailScreen(
          jobId: state.pathParameters['jobId']!,
        ),
      ),
      GoRoute(
        path: '/employer/vacancy/create/step1',
        name: 'create_vacancy_step1',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateVacancyStep1Screen(),
      ),
      GoRoute(
        path: '/employer/vacancy/create/step2',
        name: 'create_vacancy_step2',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CreateVacancyStep2Screen(),
      ),
      GoRoute(
        path: '/employer/vacancy/:vacancyId',
        name: 'vacancy_detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => VacancyDetailScreen(
          vacancyId: state.pathParameters['vacancyId']!,
        ),
      ),
      GoRoute(
        path: '/employer/vacancy/:vacancyId/applicants',
        name: 'applicants_list',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => ApplicantsListScreen(
          vacancyId: state.pathParameters['vacancyId']!,
        ),
      ),
      GoRoute(
        path: '/employer/freelancer-profile/:freelancerId',
        name: 'freelancer_profile_view',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => FreelancerPreviewScreen(
          freelancerId: state.pathParameters['freelancerId']!,
        ),
      ),
    ],
  );
});