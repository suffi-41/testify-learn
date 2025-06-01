import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../utils/helpers.dart';
import "../../utils/responsive.dart";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreen();
}

class _LoginScreen extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: UiHelpers.customAuthAppBar(context, "Get start", () {
        context.replace("/role");
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
            "Welcome Back",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Enter your details below",
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

          const SizedBox(height: 16),
          const Text("Password", style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
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
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'Password is required';
              if (value.length < 6)
                return 'Password must be at least 6 characters';
              return null;
            },
          ),

          const SizedBox(height: 24),

          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : UiHelpers.customButton(context, "Sign In", () {
                  if (!_isLoading) _handleLogin();
                }),

          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {
                context.push("/reset-password");
              },
              child: const Text("Forgot your password?"),
            ),
          ),

          const SizedBox(height: 12),
          Row(
            children: const [
              Expanded(child: Divider()),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text("Or sign in with"),
              ),
              Expanded(child: Divider()),
            ],
          ),

          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton("Google", "assets/images/google.jpg"),
              _buildSocialButton("Facebook", "assets/images/facebook.png"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(String label, String assetPath) {
    return ElevatedButton.icon(
      onPressed: () {
        // TODO: Implement social login
      },
      icon: Image.asset(assetPath, height: 24),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFF5F7FB),
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    );
  }

  // login or sign In function
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (!credential.user!.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please verify your email before logging in."),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Login successful!"),
            backgroundColor: Colors.green,
          ),
        );
        context.go('/home'); // Navigate after login
      }
    } on FirebaseAuthException catch (e) {
      String msg = "Login failed";
      if (e.code == 'user-not-found') {
        msg = "No user found with this email.";
      } else if (e.code == 'wrong-password') {
        msg = "Incorrect password.";
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Something went wrong."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
