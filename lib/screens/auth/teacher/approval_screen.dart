import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../constants/app_routes.dart';

class ApprovalPage extends StatelessWidget {
  const ApprovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final uid = currentUser?.uid;

    if (uid == null) {
      // Not logged in
      return const Scaffold(
        body: Center(child: Text("Not authenticated.")),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('teachers')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("User data not found."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final isApproved = data['isApproved'] ?? false;

          if (isApproved) {
            // ✅ Auto redirect when approved
            Future.microtask(() {
              if (context.mounted) {
                context.go(AppRoutes.teacherDashboard);
              }
            });
          }

          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                          Text(
                            'Your coaching details are submitted and will be verified within 24 hours.',
                            style: TextStyle(
                              color:
                                  Theme.of(context).textTheme.bodySmall?.color,
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
          );
        },
      ),
    );
  }
}
