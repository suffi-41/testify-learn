import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class StudentDetailsScreen extends StatelessWidget {
   final String studentId;

  const StudentDetailsScreen({super.key, required this.studentId});

  @override
  Widget build(BuildContext context) {
    // 👤 Mock student data
    final Map<String, dynamic> studentData = {
      'fullName': 'John Doe',
      'email': 'johndoe@example.com',
      'createdAt': DateTime(2024, 10, 15, 14, 30),
    };

    // 📝 Mock quiz submissions
    final List<Map<String, dynamic>> quizSubmissions = [
      {
        'quizTitle': 'Math Test 1',
        'score': 8,
        'total': 10,
        'submittedAt': DateTime(2025, 6, 10, 10, 30),
      },
      {
        'quizTitle': 'Science Quiz',
        'score': 7,
        'total': 10,
        'submittedAt': DateTime(2025, 6, 12, 14, 00),
      },
      {
        'quizTitle': 'English Grammar Test',
        'score': 9,
        'total': 10,
        'submittedAt': DateTime(2025, 6, 14, 16, 15),
      },
    ];

    final joinDateStr = DateFormat.yMMMd().add_Hm().format(
      studentData['createdAt'] as DateTime,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Student Details")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 👤 Student Info Card
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Name: ${studentData['fullName'] as String}",
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text("Email: ${studentData['email'] as String}"),
                    const SizedBox(height: 8),
                    Text("Joined on: $joinDateStr"),
                  ],
                ),
              ),
            ),

            // 📋 Quiz Submissions Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                "Quiz Submissions",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),

            // 📝 Quiz Submissions List
            quizSubmissions.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text("No quiz submissions found."),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: quizSubmissions.length,
                    itemBuilder: (context, index) {
                      final quiz = quizSubmissions[index];
                      final dateStr = DateFormat.yMMMd().add_Hm().format(
                        quiz['submittedAt'] as DateTime,
                      );

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: ListTile(
                          title: Text(quiz['quizTitle'] as String),
                          subtitle: Text('Submitted on: $dateStr'),
                          trailing: Text(
                            "${quiz['score']}/${quiz['total']}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
