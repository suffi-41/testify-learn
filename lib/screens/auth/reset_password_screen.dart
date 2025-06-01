import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/helpers.dart';
import "../../../utils/responsive.dart";

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password reset email sent!"),
          backgroundColor: Colors.green,
        ),
      );

      context.pop(); // Return to login screen
    } on FirebaseAuthException catch (e) {
      String message = "Something went wrong.";
      if (e.code == 'user-not-found') {
        message = "No user found with this email.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: UiHelpers.customAuthAppBar(context, "Back ", () {
        // Example: navigate back or to another screen
        context.pop();
      }),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ResponsiveLayout(
                mobile: _form(),
                tablet: Center(child: SizedBox(width: 500, child: _form())),
                desktop: Center(child: SizedBox(width: 500, child: _form())),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Forgot Password?",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Enter your registered email to receive a reset link.",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          const Text(
            "Email Address",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          UiHelpers.customTextField(
            context,
            hintText: "Email Address",
            controller: emailController,
            prefixIcon: const Icon(Icons.email),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) return 'Email is required';
              if (!value.contains('@')) return 'Enter a valid email';
              return null;
            },
          ),

          const SizedBox(height: 24),

          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : UiHelpers.customButton(
                  context,
                  "Send Reset Link",
                  _resetPassword,
                ),
        ],
      ),
    );
  }
}
