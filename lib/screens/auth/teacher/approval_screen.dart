import 'package:flutter/material.dart';

class ApprovalPage extends StatelessWidget {
  const ApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Illustration
              Container(
                height: 140,
                width: 140,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.verified_rounded,
                  size: 100,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),

              // Info Card
              Card(
                elevation: Theme.of(context).cardTheme.elevation,
                shape: Theme.of(context).cardTheme.shape,
                color: Theme.of(context).cardTheme.color,
                child: Container(
                  width: 300,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Logo & Title
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipOval(
                            child: Image.asset(
                              'assets/images/app_logo.jpg',
                              height: 24,
                              width: 24,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Testify Learn',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Thank you text
                      const Text(
                        'Thanks for registering!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7E3FF2),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),

                      // Subtext
                      Text(
                        'Your coaching details are submitted and will be verified within 24 hours.',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
