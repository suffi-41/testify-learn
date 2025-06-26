import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../constants/app_routes.dart';
import '../../../widgets/text_card.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class StudentListScreen extends StatefulWidget {
  final String coachingCode;
  final String searchQuery;

  const StudentListScreen({
    super.key,
    required this.coachingCode,
    this.searchQuery = '',
  });

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  late Future<List<DocumentSnapshot>> _studentsFuture;

  @override
  void initState() {
    super.initState();
    _studentsFuture = _getJoinedStudents();
  }

  Future<List<DocumentSnapshot>> _getJoinedStudents() async {
    final codeSnapshots = await FirebaseFirestore.instance
        .collectionGroup('coachingCodes')
        .where('code', isEqualTo: widget.coachingCode)
        .get();

    final studentUids = codeSnapshots.docs
        .map((doc) {
          final path = doc.reference.path;
          return path.split('/')[1]; // students/{uid}/coachingCodes/{id}
        })
        .toSet()
        .toList();

    if (studentUids.isEmpty) return [];

    List<DocumentSnapshot> allStudents = [];
    const batchSize = 10;

    for (var i = 0; i < studentUids.length; i += batchSize) {
      final batch = studentUids.sublist(
          i,
          i + batchSize > studentUids.length
              ? studentUids.length
              : i + batchSize);

      final studentsQuery = await FirebaseFirestore.instance
          .collection('students')
          .where(FieldPath.documentId, whereIn: batch)
          .get();

      allStudents.addAll(studentsQuery.docs);
    }

    return allStudents;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DocumentSnapshot>>(
      future: _studentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }

        final docs = snapshot.data ?? [];

        final filteredDocs = widget.searchQuery.isEmpty
            ? docs
            : docs.where((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final fullName =
                    data['fullName']?.toString().toLowerCase() ?? '';
                final email = data['email']?.toString().toLowerCase() ?? '';
                return fullName.contains(widget.searchQuery.toLowerCase()) ||
                    email.contains(widget.searchQuery.toLowerCase());
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
