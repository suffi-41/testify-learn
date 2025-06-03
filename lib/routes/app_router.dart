import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:redux/redux.dart';
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

// teacher screens
import '../screens/teachers/dashoard_screen.dart';

// Studnet screens
import '../screens/students/student_dashboard.dart';

class AppRouter {
  static GoRouter createRouter(Store<RootState> store) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: GoRouterRefreshStream(store.onChange),
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
        GoRoute(
          path: '/',
          redirect: (context, state) {
            // final isAuth = store.state.authState.isLoggedIn;
            final role = store.state.authState.role;

            if (role.isNotEmpty) {
              switch (role) {
                case 'student':
                  return '/student-dashboard';
                case 'teacher':
                  return '/teacher-dashboard';
                case 'admin':
                  return '/admin-dashboard';
                default:
                  return '/login';
              }
            }

            return '/login';
          },
        ),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/role', builder: (_, __) => const RoleSelectionScreen()),
        GoRoute(
          path: '/student-signup',
          builder: (_, __) => const StudentSignup(),
        ),
        GoRoute(
          path: '/teacher-signup',
          builder: (_, __) => const TeacherSignup(),
        ),
        GoRoute(
          path: '/verify-email',
          builder: (_, __) => const EmailVerificationScreen(),
        ),
        GoRoute(path: '/approval', builder: (_, __) => const ApprovalPage()),
        GoRoute(
          path: '/reset-password',
          builder: (_, __) => const ResetPasswordScreen(),
        ),

        GoRoute(
          path: '/student-dashboard',
          builder: (_, __) => StudentDashboardScreen(),
        ),
        GoRoute(
          path: '/teacher-dashboard',
          builder: (_, __) => DashoardScreen(),
        ),
        GoRoute(
          path: '/admin-dashboard',
          builder: (_, __) => const Text("Admin Dashboard"),
        ),

        // Default root with redirect logic
      ],
    );
  }
}
