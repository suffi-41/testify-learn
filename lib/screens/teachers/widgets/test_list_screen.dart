import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants/app_routes.dart';
import '../../../widgets/text_card.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TestListScreen extends StatelessWidget {
  final String uid;
  final String coachingCode;

  const TestListScreen({
    super.key,
    required this.uid,
    required this.coachingCode,
  });

  @override
  Widget build(BuildContext context) {
    final testStream = FirebaseFirestore.instance
        .collection('quizzes')
        .where('createdBy', isEqualTo: uid)
        .where('coachingCode', isEqualTo: coachingCode)
        .snapshots();

    return StreamBuilder<QuerySnapshot>(
      stream: testStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text("No tests available."));
        }

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            String createdAtStr = "";
            final timestamp = data['createdAt'];
            if (timestamp is Timestamp) {
              final date = timestamp.toDate();
              createdAtStr = DateFormat.yMMMd().add_Hm().format(date);
            }
            return TestCard(
              title: data['title'] ?? 'Untitled',
              subTitle: "Test Date: ${data['testDateTime']}" ?? 'Unknown Date',
              bottomTitle: 'Created on $createdAtStr',
              icon: Icons.description,
              onTap: () {
                context.push('${AppRoutes.testDetails}/${doc.id}');
              },
            );
          }).toList(),
        );
      },
    );
  }
}
