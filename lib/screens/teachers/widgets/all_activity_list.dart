import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants/app_routes.dart';
import '../../../widgets/text_card.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AllActivityList extends StatelessWidget {
  final String uid;
  final String coachingCode;

  const AllActivityList({
    super.key,
    required this.uid,
    required this.coachingCode,
  });

  @override
  Widget build(BuildContext context) {
    final quizzesFuture = FirebaseFirestore.instance
        .collection('quizzes')
        .where('createdBy', isEqualTo: uid)
        .where('coachingCode', isEqualTo: coachingCode)
        .get();

    final studentsFuture = FirebaseFirestore.instance
        .collection('students')
        .get();
    // .where('coachingCode', isNotEqualTo: coachingCode)

    return FutureBuilder<List<QuerySnapshot>>(
      future: Future.wait([quizzesFuture, studentsFuture]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final quizDocs = snapshot.data![0].docs;
        final studentDocs = snapshot.data![1].docs;

        final mergedList = [
          ...quizDocs.map((doc) => {'type': 'quiz', 'data': doc}),
          ...studentDocs.map((doc) => {'type': 'student', 'data': doc}),
        ];

        // Sort merged by 'createdAt'
        mergedList.sort((a, b) {
          final timeA =
              (a['data'] as DocumentSnapshot).get('createdAt') as Timestamp?;
          final timeB =
              (b['data'] as DocumentSnapshot).get('createdAt') as Timestamp?;
          return timeB?.compareTo(timeA ?? Timestamp(0, 0)) ?? 0;
        });

        if (mergedList.isEmpty) {
          return const Center(child: Text("No activity found."));
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: mergedList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = mergedList[index];
            final doc = item['data'] as DocumentSnapshot;
            final data = doc.data() as Map<String, dynamic>;

            String createdAtStr = "";
            final timestamp = data['createdAt'];
            if (timestamp is Timestamp) {
              final date = timestamp.toDate();
              createdAtStr = DateFormat.yMMMd().add_Hm().format(date);
            }

            if (item['type'] == 'quiz') {
              final testDateTime = data['testDateTime'];
            

              return TestCard(
                title: data['title'] ?? 'Untitled Test',
                subTitle: "Test Date : $testDateTime",
                bottomTitle: "Created on $createdAtStr",
                icon: Icons.assignment,
                onTap: () {
                  context.push('${AppRoutes.testDetails}/${doc.id}');
                },
              );
            } else {
              return TestCard(
                title: data['fullName'] ?? 'Unnamed Student',
                subTitle: "${data['email'] ?? 'No email'}",
                bottomTitle: 'Joined on $createdAtStr',
                imagesUrl:
                    "https://mohdbinsufiyan.vercel.app/assets/media/mypic.jpg",
                onTap: () {
                  // Navigate if needed
                },
              );
            }
          },
        );
      },
    );
  }
}
