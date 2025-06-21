import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants/app_routes.dart';
import '../../../widgets/text_card.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class StudentListScreen extends StatelessWidget {
  final String coachingCode;
  final String searchQuery; // 🔍 Add search query

  const StudentListScreen({
    super.key,
    required this.coachingCode,
    this.searchQuery = '', // default empty
  });

  @override
  Widget build(BuildContext context) {
    final testStream = FirebaseFirestore.instance
        .collection('students')
        // .where('coachingCode', isEqualTo: coachingCode)
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

        // 🔍 Filter based on search query
        final filteredDocs = searchQuery.isEmpty
            ? docs
            : docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final fullName =
                    data['fullName']?.toString().toLowerCase() ?? '';
                final email = data['email']?.toString().toLowerCase() ?? '';
                return fullName.contains(searchQuery.toLowerCase()) ||
                    email.contains(searchQuery.toLowerCase());
              }).toList();

        if (filteredDocs.isEmpty) {
          return const Center(child: Text("No matching students found."));
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredDocs.length,
          
          itemBuilder: (context, index) {
            final doc = filteredDocs[index];
            final data = doc.data() as Map<String, dynamic>;

            String createdAtStr = "";
            final timestamp = data['createdAt'];
            if (timestamp is Timestamp) {
              final date = timestamp.toDate();
              createdAtStr = DateFormat.yMMMd().add_Hm().format(date);
            }

            return TestCard(
              title: data['fullName'] ?? 'Untitled',
              subTitle: data['email'] ?? 'No email',
              bottomTitle: 'Joined on $createdAtStr',
              imagesUrl:
                  "https://mohdbinsufiyan.vercel.app/assets/media/mypic.jpg",
              onTap: () {
                context.push('${AppRoutes.studentDetails}/${doc.id}');
              },
            );
          },
        );
      },
    );
  }
}
