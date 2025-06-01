import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:testify_learn_application/utils/helpers.dart';
import "../../utils/responsive.dart";

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 5),
                Text(
                  "Welcome to Testify Learn",
                  style: Theme.of(context).textTheme.displayLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Unlock Knowledge,\nCompete, and Win Big!",
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                ResponsiveLayout(
                  mobile: Column(
                    children: [
                      _buildRoleCard(
                        context,
                        imagePath: "assets/images/student.png",
                        label: "I'm a Student",
                        onPressed: () => context.push('/student-signup'),
                      ),
                      const SizedBox(height: 24),

                      _buildRoleCard(
                        context,
                        imagePath: "assets/images/teacher.png",
                        label: "I'm a Teacher",
                        onPressed: () => context.push('/teacher-signup'),
                      ),
                    ],
                  ),
                  tablet: Expanded(
                    child: Row(
                      children: [
                        _buildRoleCard(
                          context,
                          imagePath: "assets/images/student.png",
                          label: "I'm a Student",
                          onPressed: () => context.push('/student-signup'),
                        ),
                        const SizedBox(height: 24),

                        _buildRoleCard(
                          context,
                          imagePath: "assets/images/teacher.png",
                          label: "I'm a Teacher",
                          onPressed: () => context.push('/teacher-signup'),
                        ),
                      ],
                    ),
                  ),
                  desktop: Expanded(
                    child: Row(
                      children: [
                        _buildRoleCard(
                          context,
                          imagePath: "assets/images/student.png",
                          label: "I'm a Student",
                          onPressed: () => context.push('/student-signup'),
                        ),
                        const SizedBox(height: 24),

                        _buildRoleCard(
                          context,
                          imagePath: "assets/images/teacher.png",
                          label: "I'm a Teacher",
                          onPressed: () => context.push('/teacher-signup'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    BuildContext context, {
    required String imagePath,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            imagePath,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 10),
        UiHelpers.customButton(context, label, onPressed),
      ],
    );
  }
}
