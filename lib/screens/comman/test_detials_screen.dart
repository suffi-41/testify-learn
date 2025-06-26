import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../utils/helpers.dart';
import '../../widgets/payment_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_routes.dart';

class TestDetailsScreen extends StatefulWidget {
  final String testId;
  const TestDetailsScreen({super.key, required this.testId});

  @override
  State<TestDetailsScreen> createState() => _TestDetailsScreenState();
}

class _TestDetailsScreenState extends State<TestDetailsScreen> {
  final user = FirebaseAuth.instance.currentUser;
  String role = 'student';

  @override
  void initState() {
    super.initState();
    _fetchUserRole();
  }

  void _fetchUserRole() async {
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    if (userDoc.exists) {
      setState(() {
        role = userDoc['role'] ?? 'student';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiHelpers.customAppBarForScreen(context, "Test Details",
          automaticallyImplyLeading: true),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('quizzes')
            .doc(widget.testId)
            .snapshots(),
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
          final isLive = data['isLive'] == true;

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
                if (isLive)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Chip(
                      label: const Text("LIVE",
                          style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red,
                    ),
                  ),
                const SizedBox(height: 20),
                if (role == 'admin' || role == 'teacher')
                  _buildSwitchTile("Published", isPublished),
                const SizedBox(height: 24),
                if (role == 'student') _studentActions(data, isLive),
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

  Widget _studentActions(Map<String, dynamic> testData, bool isLive) {
    final enrolledRef = FirebaseFirestore.instance
        .collection('students')
        .doc(user!.uid)
        .collection('enrolledTests')
        .doc(widget.testId);

    return FutureBuilder<DocumentSnapshot>(
      future: enrolledRef.get(),
      builder: (context, snapshot) {
        bool isEnrolled = false;
        bool hasPaid = false;

        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          isEnrolled = true;
          hasPaid = data['hasPaid'] ?? false;
        }

        if (!isEnrolled) {
          return ElevatedButton(
            onPressed: () {
              PaymentDialog.show(
                context: context,
                title: "Pay & Enroll",
                buttonText: "Pay",
                minAmount: 10,
                amount:
                    int.tryParse(testData['fee']?.replaceAll('₹', '') ?? '0') ??
                        0,
                onConfirm: (upi, amount) async {
                  final now = Timestamp.now();
                  final userDocSnap = await FirebaseFirestore.instance
                      .collection('students')
                      .doc(user!.uid)
                      .get();
                  final userDoc = userDocSnap.data() ?? {};

                  final paymentId = FirebaseFirestore.instance
                      .collection('payments')
                      .doc()
                      .id;

                  await FirebaseFirestore.instance
                      .collection('payments')
                      .doc(paymentId)
                      .set({
                    'paymentId': paymentId,
                    'studentUid': user!.uid,
                    'studentName': userDoc['name'] ?? '',
                    'amount': amount,
                    'testId': widget.testId,
                    'testTitle': testData['title'] ?? '',
                    'paidAt': now,
                    'upiId': upi,
                    'status': 'success'
                  });

                  await FirebaseFirestore.instance
                      .collection('quizzes')
                      .doc(widget.testId)
                      .collection('enrolledStudents')
                      .doc(user!.uid)
                      .set({
                    'uid': user!.uid,
                    'enrolledAt': now,
                    'hasPaid': true,
                    'paymentId': paymentId,
                    'status': 'enrolled',
                    'name': userDoc['name'] ?? '',
                  });

                  await enrolledRef.set({
                    'testId': widget.testId,
                    'title': testData['title'] ?? '',
                    'fee': amount,
                    'hasPaid': true,
                    'enrolledAt': now,
                    'status': 'enrolled',
                    'testDateTime': testData['testDateTime'],
                    'createdBy': testData['createdBy'] ?? '',
                    'paymentId': paymentId,
                  });

                  setState(() {});
                },
              );
            },
            child: const Text("Pay & Enroll"),
          );
        } else {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ElevatedButton(
                    onPressed: isLive
                        ? () {
                            // context.push(
                            //     "${AppRoutes.quizAttempt}/${widget.testId}");
                          }
                        : null,
                    child: Text(isLive ? "Join Now" : "Start Test (Disabled)"),
                  ),
                  const SizedBox(width: 16),
                  OutlinedButton(
                    onPressed: () {
                      context.push(
                          "${AppRoutes.testLeaderborad}/${widget.testId}");
                    },
                    child: const Text("Leaderboard"),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Chip(
                label: const Text("Enrolled"),
                backgroundColor: Colors.green.shade100,
              )
            ],
          );
        }
      },
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
