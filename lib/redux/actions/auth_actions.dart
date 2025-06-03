import 'package:flutter/foundation.dart';

class SetAuthLoading {
  final bool isLoading;
  SetAuthLoading(this.isLoading);
}

// login for studnets & teachers
class AuthSuccess {
  final String uid;
  final String role;
  AuthSuccess(this.uid, this.role);
}

class AuthFailure {
  final String error;
  AuthFailure(this.error);
}

class StartLogin {
  final String email;
  final String password;
  StartLogin(this.email, this.password);
}

// singup & singIn wiht google for studnets only not teahcers
class StartGoogleSignIn {}

// Student Signup
class StartStudentSignup {
  final String email, password, fullName, phone;
  final VoidCallback onSuccess;
  final Function(String) onFailure;

  StartStudentSignup({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
    required this.onSuccess,
    required this.onFailure,
  });
}

// Teacher Signup
class StartTeacherSignup {
  final String email, password, fullName, phone, coachingName, coachingAddress;
  final String teacherImageUrl;
  final String coachingImageUrl;
  final VoidCallback onSuccess;
  final Function(String) onFailure;

  StartTeacherSignup({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
    required this.coachingName,
    required this.coachingAddress,
    required this.teacherImageUrl,
    required this.coachingImageUrl,
    required this.onSuccess,
    required this.onFailure,
  });
}

// logout action classes
class LogoutRequestAction {}

class LogoutSuccessAction {}
