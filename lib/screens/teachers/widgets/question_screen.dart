import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionsListWidget extends StatelessWidget {
  final String testId;

  const QuestionsListWidget({
    super.key,
    required this.testId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('quizzes')
          .doc(testId)
          .collection('questions')
          .get(),
      builder: (context, questionSnapshot) {
        if (questionSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!questionSnapshot.hasData || questionSnapshot.data!.docs.isEmpty) {
          return const Text("No questions added.");
        }

        final questions = questionSnapshot.data!.docs;

        return Column(
          children: List.generate(questions.length, (index) {
            final question = questions[index].data() as Map<String, dynamic>;
            final List options = question['options'] ?? [];
            final int correctIndex = question['correctOptionIndex'] ?? -1;

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.shade200,
                    blurRadius: 4,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Q${index + 1}: ${question['questionText'] ?? ''}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(options.length, (i) {
                    final bool isCorrect = i == correctIndex;
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: isCorrect
                            ? Colors.green.shade100
                            : Colors.grey.shade100,
                      ),
                      child: Text(
                        "${String.fromCharCode(65 + i)}. ${options[i]}",
                        style: TextStyle(
                          fontWeight:
                              isCorrect ? FontWeight.bold : FontWeight.normal,
                          color: isCorrect ? Colors.green.shade800 : null,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            );
          }),
        );
      },
    );
  }
}
