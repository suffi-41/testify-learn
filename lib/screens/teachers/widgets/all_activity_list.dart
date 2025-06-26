import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants/app_routes.dart';
import '../../../widgets/text_card.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class AllActivityList extends StatefulWidget {
  final String uid;
  final String coachingCode;

  const AllActivityList({
    super.key,
    required this.uid,
    required this.coachingCode,
  });

  @override
  State<AllActivityList> createState() => _AllActivityListState();
}

class _AllActivityListState extends State<AllActivityList> {
  late Future<List<Map<String, dynamic>>> _allDataFuture;

  @override
  void initState() {
    super.initState();
    _allDataFuture = _fetchAllData();
  }

  Future<List<Map<String, dynamic>>> _fetchAllData() async {
    final List<Map<String, dynamic>> allData = [];

    // 1. Get quizzes created by the teacher
    final quizSnapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .where('createdBy', isEqualTo: widget.uid)
        .where('coachingCode', isEqualTo: widget.coachingCode)
        .get();

    for (final doc in quizSnapshot.docs) {
      final quizData = doc.data();
      allData.add({
        'type': 'quiz',
        'id': doc.id,
        'data': quizData,
        'createdAt': quizData['createdAt'] as Timestamp?,
      });
    }

    // 2. Get students who joined with this coaching code
    final joinedSnapshot = await FirebaseFirestore.instance
        .collectionGroup('coachingCodes')
        .where('code', isEqualTo: widget.coachingCode)
        .get();

    for (final subDoc in joinedSnapshot.docs) {
      final pathSegments = subDoc.reference.path.split('/');
      if (pathSegments.length >= 2) {
        final studentUid =
            pathSegments[1]; // students/{uid}/coachingCodes/{docId}

        final studentDoc = await FirebaseFirestore.instance
            .collection('students')
            .doc(studentUid)
            .get();

        if (studentDoc.exists) {
          final studentData = studentDoc.data()!;
          allData.add({
            'type': 'student',
            'id': studentUid,
            'data': studentData,
            'createdAt': subDoc['joinedAt'] ?? studentData['createdAt'],
          });
        }
      }
    }

    // Sort by createdAt or joinedAt
    allData.sort((a, b) {
      final aTime = a['createdAt'] as Timestamp?;
      final bTime = b['createdAt'] as Timestamp?;
      return bTime?.compareTo(aTime ?? Timestamp(0, 0)) ?? 0;
    });

    return allData;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _allDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final allData = snapshot.data ?? [];
        if (allData.isEmpty) {
          return const Center(child: Text("No activity found."));
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: allData.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = allData[index];
            final data = item['data'] as Map<String, dynamic>;
            final Timestamp? timestamp = item['createdAt'];

            final createdAtStr = timestamp != null
                ? DateFormat.yMMMd().add_Hm().format(timestamp.toDate())
                : '';

            if (item['type'] == 'quiz') {
              return TestCard(
                title: data['title'] ?? 'Untitled Test',
                subTitle: "Test Date : ${data['testDateTime'] ?? 'N/A'}",
                bottomTitle: "Created on $createdAtStr",
                icon: Icons.assignment,
                onTap: () {
                  context.push('${AppRoutes.testDetails}/${item['id']}');
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
                  // You can add navigation to student details
                },
              );
            }
          },
        );
      },
    );
  }
}
