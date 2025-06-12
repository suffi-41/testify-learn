class AppRoutes {
  // intial routes
  static const splash = '/splash';

  // authentication routes
  static const login = '/login';
  static const role = '/role';
  static const studentSingup = '/student-signup';
  static const teacherSignup = '/teacher-signup';
  static const emailVerification = '/verify-email';
  static const approval = '/approval';
  static const resetPassword = '/reset-password';

  // comman routes
  static const notifications = '/settings';

  // Studnets routes name
  static const studentDashboard = '/student-dashboard';
  static const String coachingCode = '/coaching-code';
  static const String studentProfile = '/student-profile';
  static const String studentWallet = '/student-wallet';
  static const String studentTest = '/student-test';
  static const String studentLeaderboard = '/student-leaderboard';

  // dynamic routes
  static const String testLeaderborad = '/test-leaderboard';

  // teacher routes name
  static const teacherDashboard = '/teacher-dashboard';
  static const teacherShowStudent = '/teacher-show-student';
  static const teacherProfile = '/teacher-profile';
  static const teacherWallet = '/teacher-wallet';
  static const createNewTests = '/create-new-tests';

  // admin routes name
  static const adminDashboard = '/admin-dashboard';
}
