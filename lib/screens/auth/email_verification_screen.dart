import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/firebase_service.dart';
import '../../services/firebase_service.dart';

// routes name
import '../../constants/app_routes.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  State<EmailVerificationScreen> createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Timer? _resendTimer;
  Timer? _checkTimer;
  int _secondsRemaining = 60;
  bool _canResend = false;
  bool _isEmailVerified = false;

  @override
  void initState() {
    super.initState();
    _sendVerificationEmail();
    _startResendCountdown();
    _startAutoCheckVerification();
  }

  Future<void> _checkEmailVerified() async {
    final user = FirebaseAuth.instance.currentUser;
    await _auth.currentUser?.reload();
    final isVerified = _auth.currentUser?.emailVerified ?? false;

    if (mounted && isVerified && !_isEmailVerified) {
      setState(() {
        _isEmailVerified = true;
      });
      _checkTimer?.cancel();
      final role = await getUserRole(user!.uid);
      if (role == "teacher") {
        context.replace(AppRoutes.approval);
      } else {
        context.replace(AppRoutes.joinInCoaching);
      }
    }
  }

  void _sendVerificationEmail() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
      setState(() {
        _canResend = false;
        _secondsRemaining = 60;
      });
      _startResendCountdown();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    }
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        setState(() {
          _canResend = true;
        });
        _resendTimer?.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  void _startAutoCheckVerification() {
    _checkTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkEmailVerified();
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    _checkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = _auth.currentUser?.email ?? "your email";

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 40),
                Image.asset(
                  'assets/images/app_logo.jpg', // Replace with your logo path
                  height: 100,
                ),
                const SizedBox(height: 40),
                const Text(
                  "Welcome",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text(
                  "An email  is on its way",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Text(
                  "We sent a magic link to your email \"$userEmail\".\nThe link expires in 24 hours, so be sure to use it soon",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 32),
                const Text(
                  "Go check your email!",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                const Text(
                  "If the email has not been received,\nclick on the resend button",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _canResend ? _sendVerificationEmail : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    _canResend
                        ? "Resend email"
                        : "Resend in $_secondsRemaining sec",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
