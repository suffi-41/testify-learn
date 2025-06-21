import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../utils/helpers.dart';

class TestDetailsScreen extends StatefulWidget {
  final String testId;

  const TestDetailsScreen({super.key, required this.testId});

  @override
  State<TestDetailsScreen> createState() => _TestDetailsScreenState();
}

class _TestDetailsScreenState extends State<TestDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiHelpers.customAppBarForScreen(
        context,
        "Test Details",
        automaticallyImplyLeading: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quizzes')
            .doc(widget.testId)
            .snapshots(),
        builder: (context, quizSnapshot) {
          if (quizSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!quizSnapshot.hasData || !quizSnapshot.data!.exists) {
            return const Center(child: Text('Test not found.'));
          }

          final data = quizSnapshot.data!.data() as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView(
              children: [
                _infoTile("Test Title", data['title']),
                _infoTile("Description", data['description']),
                _infoTile("Coaching Code", data['coaching_code']),
                _infoTile("Created By (UID)", data['createdBy']),
                _infoTile("Date & Time", formatDateTime(data['testDateTime'])),
                _infoTile("Fee", "₹${data['fee'] ?? '0'}"),
                _infoTile("Duration", "${data['duration']} mins"),

                const SizedBox(height: 16),

                /// ✅ Publish/Unpublish Toggle
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Published",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Switch(
                      value: (data['isPublished'] ?? false) == true,
                      onChanged: (val) async {
                        print("Switch changed: $val");
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: Text(
                              val ? "Publish Test?" : "Unpublish Test?",
                            ),
                            content: Text(
                              val
                                  ? "Are you sure you want to publish this test?"
                                  : "Are you sure you want to unpublish this test?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text("Yes"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await FirebaseFirestore.instance
                              .collection('quizzes')
                              .doc(widget.testId)
                              .update({'isPublished': val});

                          // Force rebuild (optional, for extra safety)
                          setState(() {});
                        }
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Text(
                  "Questions",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),

                /// 🔽 Fetch Questions Subcollection
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('quizzes')
                      .doc(widget.testId)
                      .collection('questions')
                      .get(),
                  builder: (context, questionSnapshot) {
                    if (questionSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!questionSnapshot.hasData ||
                        questionSnapshot.data!.docs.isEmpty) {
                      return const Text("No questions added.");
                    }

                    final questions = questionSnapshot.data!.docs;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(questions.length, (index) {
                        final question =
                            questions[index].data() as Map<String, dynamic>;
                        final String questionText =
                            question['questionText'] ?? 'Question missing';
                        final List<dynamic> options = question['options'] ?? [];
                        final int correctAnswer =
                            question['correctOptionIndex'] ?? -1;

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Q${index + 1}: $questionText",
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ...List.generate(options.length, (optIndex) {
                                final String optionText = options[optIndex];
                                final bool isCorrect =
                                    optIndex == correctAnswer;

                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 5,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isCorrect
                                        ? Colors.green.shade50
                                        : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isCorrect
                                          ? Colors.green
                                          : Colors.grey.shade300,
                                      width: isCorrect ? 2 : 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        "${String.fromCharCode(65 + optIndex)}. ",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: isCorrect
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isCorrect
                                              ? Colors.green
                                              : Colors.black87,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          optionText,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: isCorrect
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isCorrect
                                                ? Colors.green.shade800
                                                : Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      }),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _infoTile(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(value ?? "N/A", style: const TextStyle(fontSize: 16)),
          ),
        ],
      ),
    );
  }

  String formatDateTime(dynamic dateTimeValue) {
    if (dateTimeValue is Timestamp) {
      final date = dateTimeValue.toDate();
      return DateFormat.yMMMd().add_jm().format(date);
    }
    return dateTimeValue?.toString() ?? 'Unknown';
  }
}
