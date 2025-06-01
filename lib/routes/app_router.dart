import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../screens/auth/role_screen.dart';

// splash screen
import "../screens/splash_screen.dart";

//login screen
import "../screens/auth/login_screen.dart";

// signup screen
import "../screens/auth/student/student_signup_screen.dart";
import "../screens/auth/teacher/teacher_signup_screen.dart";

// Email verification screen
import '../screens/auth/email_verification_screen.dart';
// Approval screen
import "../screens/auth/teacher/approval_screen.dart";

// home screen
import "../screens/home_screen.dart";

// Reset password screen
import "../screens/auth/reset_password_screen.dart";

import "../screens/teachers/dashoard_screen.dart";

class AppRouter {
  static final GoRouter goRouter = GoRouter(
    // initialLocation: '/reset-password',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      // GoRoute(path: '/', redirect: (_, __) => '/role'),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/role',
        builder: (context, state) => const RoleSelectionScreen(),
      ),

      GoRoute(
        path: '/student-signup',
        builder: (context, state) => const StudentSignup(),
      ),
      GoRoute(
        path: '/teacher-signup',
        builder: (context, state) => const TeacherSignup(),
      ),
      GoRoute(
        path: '/verify-email',
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: '/student-dashboard',
        builder: (context, state) => const Text("student dashboard"),
      ),

      GoRoute(
        path: '/approval',
        builder: (context, state) => const ApprovalPage(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),

      GoRoute(path: "/home", builder: (context, state) => HomeScreen()),
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const Text("Admin"),
      ),
      GoRoute(
        path: "/teacher-dashboard",
        builder: (context, state) => DashoardScreen(),
      ),
    ],
    redirect: (context, state) {
      // Add authentication redirect logic here later
      return null;
    },
  );
}
