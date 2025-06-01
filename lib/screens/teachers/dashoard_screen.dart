import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class DashoardScreen extends StatelessWidget {
  const DashoardScreen({super.key});
    Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      context.go('/student-login'); // Navigate after logout
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error signing out: $e')));
    }
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(title: Text("Teacher dashboard")),
      body: Center(child: ElevatedButton(
          onPressed: () => _signOut(context), // ✅ Wrap to pass context
          child: const Text("Logout"),
        ),),
    );
  }
}
