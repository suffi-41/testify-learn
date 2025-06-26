import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firebase_service.dart';
import '../constants/app_routes.dart';

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
import '../screens/students/coaching_code_screen.dart';
import '../screens/comman/notifications_screen.dart';
import '../screens/comman/test_detials_screen.dart';
import '../screens/comman/test_leaderboard.dart';
import '../screens/comman/studnets_detiails_screen.dart';
import '../screens/students/student_main_scaffold.dart';
import '../screens/students/tests_screen.dart';
import '../screens/comman/wallet_screen.dart';
import '../screens/students/leaderboard_screen.dart';
import '../screens/students/student_profile.dart';
import '../screens/students/quiz_attend_screen.dart';
import '../screens/teachers/teacher_main_scaffold.dart';
import '../screens/teachers/teacher_dashboard.dart';
import '../screens/teachers/students_screen.dart';
import '../screens/teachers/create_test_screen.dart';
import '../screens/teachers/profile_screen.dart';
import '../screens/teachers/edit_profile_screen.dart';

class AppRouter {
  static final _publicRoutes = [
    AppRoutes.splash,
    AppRoutes.login,
    AppRoutes.role,
    AppRoutes.studentSingup,
    AppRoutes.teacherSignup,
    AppRoutes.resetPassword,
    AppRoutes.emailVerification,
  ];

  static Future<GoRouter> createRouter() async {
    return GoRouter(
      initialLocation: AppRoutes.splash,
      redirect: (context, state) async {
        final prefs = await SharedPreferences.getInstance();
        final uid = prefs.getString('uid') ?? '';
        final role = await getUserRole(uid);
        final isLoggedIn = uid.isNotEmpty;
        final isPublicRoute = _publicRoutes.contains(state.uri.path);

        final user = FirebaseAuth.instance.currentUser;

        // ✅ Redirect unverified users to email verification screen
        if (user != null &&
            !user.emailVerified &&
            state.uri.path != AppRoutes.emailVerification &&
            !_publicRoutes.contains(state.uri.path)) {
          return AppRoutes.emailVerification;
        }

        // ✅ Redirect unapproved teachers to approval screen
        if (role == 'teacher' &&
            isLoggedIn &&
            state.uri.path != AppRoutes.approval &&
            !_publicRoutes.contains(state.uri.path)) {
          final doc = await FirebaseFirestore.instance
              .collection('teachers')
              .doc(uid)
              .get();

          final isApproved = doc.data()?['isApproved'] ?? false;

          if (!isApproved) return AppRoutes.approval;
        }

        // ✅ Allow public routes
        if (isPublicRoute) return null;

        // ✅ Redirect unauthenticated users
        if (!isLoggedIn) return AppRoutes.login;

        // ✅ Root path redirection based on role
        if (state.uri.path == '/' || state.uri.path == AppRoutes.splash) {
          if (role == 'student') return AppRoutes.joinInCoaching;
          if (role == 'teacher') return AppRoutes.teacherDashboard;
          if (role == 'admin') return AppRoutes.adminDashboard;
          return AppRoutes.login;
        }

        // ✅ Restrict student-only routes
        if (state.uri.path.startsWith('/student') && role != 'student') {
          return role == 'teacher'
              ? AppRoutes.teacherDashboard
              : AppRoutes.login;
        }

        // ✅ Restrict teacher-only routes
        if (state.uri.path.startsWith('/teacher') && role != 'teacher') {
          return role == 'student' ? AppRoutes.joinInCoaching : AppRoutes.login;
        }

        return null;
      },
      routes: [
        GoRoute(
            path: AppRoutes.splash, builder: (_, __) => const SplashScreen()),
        GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
        GoRoute(path: AppRoutes.login, builder: (_, __) => const LoginScreen()),
        GoRoute(
            path: AppRoutes.role,
            builder: (_, __) => const RoleSelectionScreen()),
        GoRoute(
            path: AppRoutes.studentSingup,
            builder: (_, __) => const StudentSignup()),
        GoRoute(
            path: AppRoutes.teacherSignup,
            builder: (_, __) => const TeacherSignup()),
        GoRoute(
            path: AppRoutes.resetPassword,
            builder: (_, __) => const ResetPasswordScreen()),
        GoRoute(
            path: AppRoutes.emailVerification,
            builder: (_, __) => const EmailVerificationScreen()),
        GoRoute(
            path: AppRoutes.approval, builder: (_, __) => const ApprovalPage()),
        GoRoute(
            path: AppRoutes.notifications,
            builder: (_, __) => NotificationScreen()),
        GoRoute(
            path: AppRoutes.joinInCoaching,
            builder: (_, __) => CoachingCodeScreen()),

        // Student Shell
        ShellRoute(
          builder: (context, state, child) => StudentMainScaffold(child: child),
          routes: [
            GoRoute(
                path: AppRoutes.studentDashboard,
                builder: (_, __) => StudentDashboard()),
            GoRoute(
                path: AppRoutes.studentTest,
                builder: (_, __) => const TestScreen()),
            GoRoute(
                path: AppRoutes.studentLeaderboard,
                builder: (_, __) => const LeaderboardScreen()),
            GoRoute(
                path: AppRoutes.studentProfile,
                builder: (_, __) => const StudentProfileScreen()),
            GoRoute(
                path: AppRoutes.studentWallet,
                builder: (_, __) => const WalletScreen()),
          ],
        ),

        // Test Details
        GoRoute(
          path: '${AppRoutes.testLeaderborad}/:id',
          builder: (context, state) =>
              TestLeaderboardScreen(testId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '${AppRoutes.testDetails}/:id',
          builder: (context, state) =>
              TestDetailsScreen(testId: state.pathParameters['id']!),
        ),

        GoRoute(
          path: '${AppRoutes.takeTest}/:id',
          builder: (context, state) {
            final quizId = state.pathParameters['id']!;
            final extra = state.extra as Map<String, dynamic>? ?? {};

            return QuizAttendScreen(
              quizId: quizId,
              title: extra['title'] ?? 'Untitled',
              durationInMinutes:
                  int.tryParse(extra['duration']?.toString() ?? '') ?? 30,
            );
          },
        ),

        // Teacher Shell
        ShellRoute(
          builder: (context, state, child) => TeacherMainScaffold(child: child),
          routes: [
            GoRoute(
                path: AppRoutes.teacherDashboard,
                builder: (_, __) => TeacherDashboard()),
            GoRoute(
                path: AppRoutes.teacherShowStudent,
                builder: (_, __) => const StudentsScreen()),
            GoRoute(
                path: AppRoutes.createNewTests,
                builder: (_, __) => const CreateTestScreen()),
            GoRoute(
                path: AppRoutes.teacherWallet,
                builder: (_, __) => const WalletScreen()),
            GoRoute(
                path: AppRoutes.teacherProfile,
                builder: (_, __) => const TeacherProfileScreen()),
          ],
        ),

        GoRoute(
          path: '${AppRoutes.studentDetails}/:id',
          builder: (context, state) =>
              StudentDetailsScreen(studentId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '${AppRoutes.editTeacherinfo}/:id',
          builder: (context, state) {
            final uid = state.pathParameters['id']!;
            final data = state.extra as Map<String, dynamic>? ?? {};
            return EditTeacherInfoScreen(initialData: data, uid: uid);
          },
        ),
        GoRoute(
          path: AppRoutes.adminDashboard,
          builder: (_, __) => const Text("Admin Dashboard"),
        ),
      ],
    );
  }
}
