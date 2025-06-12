import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';
import 'package:testify_learn_application/constants/app_routes.dart';
import '../models/root_state.dart';
import '../utils/go_router_refresh_stream.dart';

// Screens
import '../screens/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/role_screen.dart';
import '../screens/auth/student/student_signup_screen.dart';
import '../screens/auth/teacher/teacher_signup_screen.dart';
import '../screens/auth/email_verification_screen.dart';
import '../screens/auth/teacher/approval_screen.dart';
import '../screens/auth/reset_password_screen.dart';

import '../screens/students/student_dashboard.dart';
import "../screens/students/coaching_code_screen.dart";

// comman screens
import '../screens/comman/notifications_screen.dart';
// dynamic routes screen for test leader board
import '../screens/comman/test_leaderboard.dart';

// 👇 Import the persistent scaffold for student
import '../screens/students/student_main_scaffold.dart';
import '../screens/students/tests_screen.dart';
import '../screens/comman/wallet_screen.dart';
import '../screens/students/leaderboard_screen.dart';
import '../screens/students/student_profile.dart';
import '../screens/students/quiz_taken_screen.dart';

// teacher
import '../screens/teachers/teacher_main_scaffold.dart';
import '../screens/teachers/teacher_dashboard.dart';
import '../screens/teachers/students_screen.dart';
import '../screens/teachers/create_test_screen.dart';

class AppRouter {
  static final _publicRoutes = [
    AppRoutes.splash,
    AppRoutes.login,
    AppRoutes.role,
    AppRoutes.studentSingup,
    AppRoutes.teacherSignup,
    AppRoutes.resetPassword,
  ];

  static GoRouter createRouter(Store<RootState> store) {
    // Redirect logic for authentication
    String? _guardRoute(BuildContext context, GoRouterState state) {
      final isLoggedIn = store.state.authState.uid.isNotEmpty;
      final userRole = store.state.authState.role;
      final isPublicRoute = _publicRoutes.contains(state.uri.path);

      // Allow access to public routes even when not logged in
      if (isPublicRoute) {
        return null;
      }

      // If not logged in and trying to access protected route, redirect to login
      if (!isLoggedIn) {
        return AppRoutes.login;
      }

      // Role-based route protection
      if (state.uri.path.startsWith('/student')) {
        if (userRole != 'student') {
          return userRole == 'teacher'
              ? AppRoutes.teacherDashboard
              : AppRoutes.login;
        }
      } else if (state.uri.path.startsWith('/teacher')) {
        if (userRole != 'teacher') {
          return userRole == 'student'
              ? AppRoutes.studentDashboard
              : AppRoutes.login;
        }
      }

      return null;
    }

    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: GoRouterRefreshStream(store.onChange),
      redirect: _guardRoute,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          builder: (_, __) => const SplashScreen(),
        ),
        GoRoute(
          path: '/',
          redirect: (context, state) {
            final role = store.state.authState.role;
            if (role.isNotEmpty) {
              switch (role) {
                case 'student':
                  return AppRoutes.studentDashboard;
                case 'teacher':
                  return AppRoutes.teacherDashboard;
                case 'admin':
                  return AppRoutes.adminDashboard;
                default:
                  return AppRoutes.login;
              }
            }
            return AppRoutes.login;
          },
        ),

        // Public routes
        GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
        GoRoute(
          path: AppRoutes.role,
          builder: (_, __) => const RoleSelectionScreen(),
        ),
        GoRoute(
          path: AppRoutes.studentSingup,
          builder: (_, __) => const StudentSignup(),
        ),
        GoRoute(
          path: AppRoutes.teacherSignup,
          builder: (_, __) => const TeacherSignup(),
        ),
        GoRoute(
          path: AppRoutes.resetPassword,
          builder: (_, __) => const ResetPasswordScreen(),
        ),

        // Protected routes that require authentication
        GoRoute(
          path: AppRoutes.emailVerification,
          builder: (_, __) => const EmailVerificationScreen(),
        ),
        GoRoute(
          path: AppRoutes.approval,
          builder: (_, __) => const ApprovalPage(),
        ),

        GoRoute(
          path: AppRoutes.notifications,
          builder: (_, _) => NotificationScreen(),
        ),

        /// Student Routes with Bottom Navigation (Protected)
        ShellRoute(
          builder: (context, state, child) => StudentMainScaffold(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.studentDashboard,
              builder: (_, __) => StudentDashboard(),
            ),
            GoRoute(
              path: AppRoutes.studentTest,
              builder: (_, __) => const TestScreen(),
            ),
            GoRoute(
              path: AppRoutes.studentLeaderboard,
              builder: (_, __) => const LeaderboardScreen(),
            ),
            GoRoute(
              path: AppRoutes.studentProfile,
              builder: (_, __) => const StudentProfileScreen(),
            ),
            GoRoute(
              path: AppRoutes.studentWallet,
              builder: (_, __) => const WalletScreen(),
            ),
          ],
        ),

        // Dynamic routes
        GoRoute(
          path: '${AppRoutes.testLeaderborad}/:id',
          builder: (context, state) =>
              TestLeaderboardScreen(testId: state.pathParameters['id']!),
        ),

        /// Teacher route (Protected)
        ShellRoute(
          builder: (context, state, child) => TeacherMainScaffold(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.teacherDashboard,
              builder: (_, __) => TeacherDashboard(),
            ),
            GoRoute(
              path: AppRoutes.teacherShowStudent,
              builder: (_, __) => const StudentsScreen(),
            ),
            GoRoute(
              path: AppRoutes.createNewTests,
              builder: (_, __) => const CreateTestScreen(),
            ),
            GoRoute(
              path: AppRoutes.teacherWallet,
              builder: (_, __) => const WalletScreen(),
            ),
          ],
        ),

        /// Admin route (Protected)
        GoRoute(
          path: AppRoutes.adminDashboard,
          builder: (_, __) => const Text("Admin Dashboard"),
        ),
      ],
    );
  }
}
