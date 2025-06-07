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
import '../screens/teachers/dashoard_screen.dart';
import '../screens/students/student_dashboard.dart';
import "../screens/students/coaching_code_screen.dart";

// 👇 Import the persistent scaffold
import '../screens/students/student_main_scaffold.dart';
import '../screens/students/tests_screen.dart';
import '../screens/comman/wallet_screen.dart';
import '../screens/students/leaderboard_screen.dart';
import '../screens/students/student_profile.dart';
import '../screens/students/quiz_taken_screen.dart';

class AppRouter {
  static GoRouter createRouter(Store<RootState> store) {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      refreshListenable: GoRouterRefreshStream(store.onChange),
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
                  return AppRoutes.tacherDashboard;
                case 'admin':
                  return AppRoutes.adminDashboard;
                default:
                  return AppRoutes.login;
              }
            }
            return AppRoutes.login;
          },
        ),
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
          path: AppRoutes.emailVerification,
          builder: (_, __) => const EmailVerificationScreen(),
        ),
        GoRoute(
          path: AppRoutes.approval,
          builder: (_, __) => const ApprovalPage(),
        ),
        GoRoute(
          path: AppRoutes.resetPassword,
          builder: (_, __) => const ResetPasswordScreen(),
        ),

        /// ✅ Student Routes with Bottom Navigation
        ShellRoute(
          builder: (context, state, child) => StudentMainScaffold(child: child),
          routes: [
            GoRoute(
              path: AppRoutes.studentDashboard,
              builder: (_, __) => StudentDashboard(),
            ),
            GoRoute(
              path: '/student-tests',
              builder: (_, __) => const TestScreen(),
            ),
            GoRoute(
              path: '/student-rank',
              builder: (_, __) => const LeaderboardScreen(),
            ),
            GoRoute(
              path: '/student-profile',
              builder: (_, __) => const TakenTestReviewScreen(),
            ),
            GoRoute(
              path: '/student-wallet',
              builder: (_, __) => const WalletScreen(),
            ),
           
          ],
        ),

        /// Teacher route
        GoRoute(
          path: AppRoutes.tacherDashboard,
          builder: (_, __) => DashoardScreen(),
        ),

        /// Admin route (placeholder)
        GoRoute(
          path: AppRoutes.adminDashboard,
          builder: (_, __) => const Text("Admin Dashboard"),
        ),
      ],
    );
  }
}
