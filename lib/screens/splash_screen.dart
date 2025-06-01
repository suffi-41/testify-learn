import 'package:flutter/material.dart';
import 'dart:async';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0;

  @override
  void initState() {
    super.initState();

    // Fade-in animation
    Future.delayed(const Duration(milliseconds: 200), () {
      setState(() {
        _opacity = 1.0;
      });
    });

    // Check auth state
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('teachers')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data();
          final role = data?['role'];
          if (role == "teacher") {
            context.replace("/teacher-dashboard");
          } else {
            context.replace("/home");
          }
        } else {
          // No doc found → likely new user
          Timer(const Duration(seconds: 2), () {
            context.go("/login");
          });
        }
      } else {
        // Not logged in
        Timer(const Duration(seconds: 2), () {
          context.go("/login");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(seconds: 2),
          curve: Curves.easeInOut,
          child: Hero(
            tag: 'app-logo',
            child: Container(
              padding: const EdgeInsets.all(24),
              child: Image.asset(
                "assets/images/app_logo.jpg", // Replace with your logo path
                width: 120,
                height: 120,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
