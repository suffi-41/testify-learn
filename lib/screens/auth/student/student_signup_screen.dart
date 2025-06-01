import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../utils/helpers.dart';
import "../../../utils/responsive.dart";

class StudentSignup extends StatefulWidget {
  const StudentSignup({super.key});

  @override
  State<StudentSignup> createState() => _StudentSignupState();
}

class _StudentSignupState extends State<StudentSignup> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: UiHelpers.customAuthAppBar(context, "Sign In", () {
        context.replace("/student-login");
      }),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: ResponsiveLayout(
          mobile: _buildSignupForm(),
          tablet: Center(
            child: SizedBox(width: 500, child: _buildSignupForm()),
          ),
          desktop: Center(
            child: SizedBox(width: 500, child: _buildSignupForm()),
          ),
        ),
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Create Student Account",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Fill in your personal details",
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          UiHelpers.sectionTitle("Student Details"),
          const SizedBox(height: 12),

          UiHelpers.customTextField(
            context,
            hintText: "Full Name",
            controller: fullNameController,
            prefixIcon: const Icon(Icons.person),
            validator: (value) =>
                value == null || value.isEmpty ? 'Full name is required' : null,
          ),

          const SizedBox(height: 16),
          UiHelpers.customTextField(
            context,
            hintText: "Email Address",
            controller: emailController,
            prefixIcon: const Icon(Icons.email),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => value == null || !value.contains('@')
                ? 'Enter a valid email'
                : null,
          ),

          const SizedBox(height: 16),
          UiHelpers.customTextField(
            context,
            hintText: "Phone Number",
            controller: phoneController,
            prefixIcon: const Icon(Icons.phone),
            keyboardType: TextInputType.phone,
            validator: (value) => value == null || value.length != 10
                ? 'Enter a 10-digit phone number'
                : null,
          ),

          const SizedBox(height: 16),
          UiHelpers.customTextField(
            context,
            hintText: "Password",
            controller: passwordController,
            prefixIcon: const Icon(Icons.lock),
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (value) => value != null && value.length < 6
                ? 'Password must be at least 6 characters'
                : null,
          ),

          const SizedBox(height: 32),

          // Show loading indicator or button
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : UiHelpers.customButton(context, "Create Account", () async {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      final credential = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                            email: emailController.text.trim(),
                            password: passwordController.text.trim(),
                          );
                      await credential.user!.sendEmailVerification();
                      await FirebaseFirestore.instance
                          .collection('students')
                          .doc(credential.user!.uid)
                          .set({
                            'uid': credential.user!.uid,
                            'role': "student",
                            'fullName': fullNameController.text.trim(),
                            'email': emailController.text.trim(),
                            'phone': phoneController.text.trim(),
                            'createdAt': Timestamp.now(),
                          });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Verification email sent. Please check your inbox.",
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );

                      context.go('/verify-email');
                    } on FirebaseAuthException catch (e) {
                      String message = "Account creation failed";
                      if (e.code == 'email-already-in-use') {
                        message = "Email already in use.";
                      } else if (e.code == 'weak-password') {
                        message = "Password is too weak.";
                      } else if (e.code == 'invalid-email') {
                        message = "Invalid email format.";
                      }
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(message),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Something went wrong."),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } finally {
                      setState(() {
                        _isLoading = false;
                      });
                    }
                  }
                }),

          const SizedBox(height: 24),
          Row(
            children: const [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text("Or sign up with"),
              ),
              Expanded(child: Divider()),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
