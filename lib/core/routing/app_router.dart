import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/assessments/presentation/assessment_results_screen.dart';
import '../../features/assessments/presentation/quiz_assessment_screen.dart';
import '../../features/auth/presentation/auth_screen.dart';
import '../../features/dashboard/presentation/student_dashboard_screen.dart';
import '../../features/facilitator/presentation/assessment_authoring_screen.dart';
import '../../features/facilitator/presentation/facilitator_dashboard_screen.dart';
import '../../features/learning_gaps/presentation/learning_gaps_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/study_plans/presentation/study_plan_screen.dart';
import '../../features/tutor/presentation/ai_tutor_screen.dart';
import '../widgets/shell_scaffold.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),

      // Shell Route for persistent header and bottom navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return ShellScaffold(
            location: state.uri.path,
            child: child,
          );
        },
        routes: [
          // Student Dashboard (Screen 1)
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const StudentDashboardScreen(),
          ),

          // Learning Gaps Diagnostic (Screen 3)
          GoRoute(
            path: '/learn',
            builder: (context, state) => const LearningGapsScreen(),
          ),

          // AI Tutor Study Companion (Screen 2)
          GoRoute(
            path: '/tutor',
            builder: (context, state) => const AiTutorScreen(),
          ),

          // Personalized Study Plan (Screen 4)
          GoRoute(
            path: '/plan',
            builder: (context, state) => const StudyPlanScreen(),
          ),

          // Profile & Settings (Screen 9)
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),

          // Facilitator Cohort Dashboard (Screen 7)
          GoRoute(
            path: '/cohort',
            builder: (context, state) => const FacilitatorDashboardScreen(),
          ),

          // Facilitator Assessment Authoring (Screen 8)
          GoRoute(
            path: '/authoring',
            builder: (context, state) => const AssessmentAuthoringScreen(),
          ),
        ],
      ),

      // Full screen Quiz Assessment (Screen 5)
      GoRoute(
        path: '/quiz/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'a0000000-0000-0000-0000-000000000001';
          return QuizAssessmentScreen(assessmentId: id);
        },
      ),

      // Full screen Assessment Results (Screen 6)
      GoRoute(
        path: '/results/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'a0000000-0000-0000-0000-000000000001';
          return AssessmentResultsScreen(assessmentId: id);
        },
      ),
    ],
  );
});
