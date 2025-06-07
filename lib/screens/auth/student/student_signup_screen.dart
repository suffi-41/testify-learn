import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/helpers.dart';
import "../../../utils/responsive.dart";

// routes name
import "../../../constants/app_routes.dart";

// redux
import 'package:flutter_redux/flutter_redux.dart';
import '../../../redux/actions/auth_actions.dart';
import '../../../models/root_state.dart';

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
      appBar: UiHelpers.customAuthAppBar(context, "Sign In", () {
        context.replace(AppRoutes.login);
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
          largeDesttop: Center(
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

                    final String email = emailController.text.trim();
                    final String password = passwordController.text.trim();
                    final String name = fullNameController.text.trim();
                    final String phone = phoneController.text.trim();

                    final store = StoreProvider.of<RootState>(context);

                    store.dispatch(
                      StartStudentSignup(
                        email: email,
                        password: password,
                        fullName: name,
                        phone: phone,
                        onSuccess: () {
                          setState(() {
                            _isLoading = false;
                          });
                          UiHelpers.showSnackbar(
                            context,
                            "Signup successful",
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondary,
                          );
                          context.go(AppRoutes.emailVerification);
                        },
                        onFailure: (error) {
                          setState(() {
                            _isLoading = false;
                          });
                          UiHelpers.showSnackbar(
                            context,
                            "Signup failed: $error",
                          );
                        },
                      ),
                    );
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
