import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../utils/helpers.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_routes.dart';

class TestDetailsScreen extends StatefulWidget {
  final String testId;
  const TestDetailsScreen({super.key, required this.testId});

  @override
  State<TestDetailsScreen> createState() => _TestDetailsScreenState();
}

class _TestDetailsScreenState extends State<TestDetailsScreen> {
  late final Stream<DocumentSnapshot> _quizStream;

  @override
  void initState() {
    super.initState();
    _quizStream = FirebaseFirestore.instance
        .collection('quizzes')
        .doc(widget.testId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiHelpers.customAppBarForScreen(context, "Test Details",
          automaticallyImplyLeading: true),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _quizStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Test not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final fee =
              int.tryParse(data['fee']?.replaceAll('₹', '') ?? '0') ?? 0;
          final isPublished = data['isPublished'] ?? false;
          final isLive = data['status'] == "Live";

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _modernTile("Title", data['title']),
                _modernTile("Description", data['description']),
                _modernTile(
                    "Date & Time", formatDateTime(data['testDateTime'])),
                _modernTile("Fee", "₹$fee"),
                _modernTile("Duration", "${data['duration']} mins"),
                _modernTile("Status", isLive ? "Live" : "Not Live"),
                const SizedBox(height: 20),
                _buildSwitchTile("Published", isPublished),
                const SizedBox(height: 20),
                isPublished == true
                    ? SizedBox(
                        width: 200,
                        child: UiHelpers.customButton(
                          context,
                          "Attendance",
                          () {
                            context.push(
                              '${AppRoutes.studentsAttandance}/${widget.testId}',
                            );
                          },
                        ),
                      )
                    : const SizedBox.shrink(), // If false, show nothing
                const SizedBox(height: 24),
                Text("Questions",
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                _buildQuestionsList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _modernTile(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey.shade100,
        ),
        child: Row(
          children: [
            Expanded(
                flex: 3,
                child: Text("$label:",
                    style: const TextStyle(fontWeight: FontWeight.bold))),
            Expanded(flex: 5, child: Text(value ?? 'N/A')),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String label, bool initialValue) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        Switch(
          value: initialValue,
          onChanged: (val) async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text(val ? "Publish Test?" : "Unpublish Test?"),
                content:
                    Text(val ? "Publish this test?" : "Unpublish this test?"),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text("Cancel")),
                  TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text("Yes")),
                ],
              ),
            );

            if (confirm == true) {
              await FirebaseFirestore.instance
                  .collection('quizzes')
                  .doc(widget.testId)
                  .update({'isPublished': val});
              setState(() {});
            }
          },
        )
      ],
    );
  }

  Widget _buildQuestionsList() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.testId)
          .collection('questions')
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("No questions available.");
        }

        final questions = snapshot.data!.docs;

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
                        fontWeight: FontWeight.w600, fontSize: 16),
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

  String formatDateTime(dynamic value) {
    if (value is Timestamp) {
      return DateFormat.yMMMd().add_jm().format(value.toDate());
    }
    return value?.toString() ?? 'Unknown';
  }
}
