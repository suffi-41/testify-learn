import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../widgets/tests_card_widget.dart';
import '../../utils/helpers.dart';
import '../../widgets/payment_dialog.dart';
import '../../constants/app_routes.dart';
import '../../utils/loacl_storage.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int selectedFilter = 0;
  String? _coachingCode;
  String? _uid;
  bool _isLoading = true;
  final filters = ['All', 'Upcoming', 'Live', 'Enrolled', 'Completed'];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final code = await getLoacalStorage("coachingCode");
    final uid = await getLoacalStorage("uid");
    setState(() {
      _coachingCode = code;
      _uid = uid;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiHelpers.customAppBarForScreen(context, "Tests"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterChips(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('quizzes')
                        .where('coachingCode', isEqualTo: _coachingCode!)
                        .where('isPublished', isEqualTo: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text("Error: ${snapshot.error}"));
                      }

                      final docs = snapshot.data?.docs ?? [];

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: docs.length,
                        itemBuilder: (context, i) {
                          final doc = docs[i];
                          final data = doc.data() as Map<String, dynamic>;

                          final isCompleted = data['isCompleted'] == true;
                          final isLive = data['isLive'] == true;
                          final feeString = data['fee']?.toString() ?? "0";
                          final amount =
                              int.tryParse(feeString.replaceAll('₹', '')) ?? 0;

                          final testDateTimeRaw =
                              data['testDateTime']?.toString() ?? '';
                          String datePart = 'Unknown Date';
                          String timePart = 'Unknown Time';

                          try {
                            final dt = DateFormat("dd-MM-yyyy h:mm a")
                                .parse(testDateTimeRaw);
                            datePart = DateFormat("dd-MM-yyyy").format(dt);
                            timePart = DateFormat("h:mm a").format(dt);
                          } catch (e) {
                            print("Date parse error: $e");
                          }

                          return FutureBuilder<List<dynamic>>(
                            future: Future.wait([
                              FirebaseFirestore.instance
                                  .collection('quizzes')
                                  .doc(doc.id)
                                  .collection('enrolledStudents')
                                  .doc(_uid)
                                  .get(),
                              FirebaseFirestore.instance
                                  .collection('quizzes')
                                  .doc(doc.id)
                                  .collection('enrolledStudents')
                                  .get(),
                            ]),
                            builder: (context, futureSnapshot) {
                              if (!futureSnapshot.hasData) {
                                return const SizedBox.shrink();
                              }

                              final enrolledDocSnap =
                                  futureSnapshot.data![0] as DocumentSnapshot;
                              final enrolledListSnap =
                                  futureSnapshot.data![1] as QuerySnapshot;

                              final enrolledData = enrolledDocSnap.data()
                                  as Map<String, dynamic>?;
                              final isEnrolled = enrolledDocSnap.exists;
                              final isPaid = enrolledData?['hasPaid'] ?? false;
                              final enrolledCount = enrolledListSnap.size;

                              String testStatus = 'Upcoming';
                              if (isCompleted)
                                testStatus = 'Completed';
                              else if (isLive)
                                testStatus = 'Live';
                              else if (isEnrolled && isPaid)
                                testStatus = 'Enrolled';

                              if (selectedFilter != 0 &&
                                  ((selectedFilter == 1 &&
                                          testStatus != 'Upcoming') ||
                                      (selectedFilter == 2 &&
                                          testStatus != 'Live') ||
                                      (selectedFilter == 3 &&
                                          testStatus != 'Enrolled') ||
                                      (selectedFilter == 4 &&
                                          testStatus != 'Completed'))) {
                                return const SizedBox.shrink();
                              }

                              final actionLabel = isCompleted
                                  ? 'Leaderboard'
                                  : (isLive && isPaid)
                                      ? 'Join Now'
                                      : isPaid
                                          ? 'Enrolled'
                                          : '₹$amount';

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Stack(
                                  children: [
                                    TestCard(
                                      subject: data['title'] ?? 'Untitled Test',
                                      date: datePart,
                                      time: timePart,
                                      duration: data['duration'] ?? 'Unknown',
                                      mcqCount:
                                          data['totalQuestions']?.toString() ??
                                              '0',
                                      status: testStatus,
                                      actionLabel: actionLabel,
                                      actionColor: isCompleted
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : isPaid
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Colors.green,
                                      extraInfo:
                                          'Enrolled: $enrolledCount students',
                                      onPressed: () async {
                                        if (isLive && isPaid) {
                                          context.go(
                                              '${AppRoutes.takeTest}/${doc.id}',
                                              extra: {
                                                'title': data['title'],
                                                'duration': data['duration'].split(" ")[0],
                                              });
                                        } else if (isCompleted && isPaid) {
                                          context.push(
                                              '${AppRoutes.testLeaderborad}/${doc.id}');
                                        } else if (isPaid) {
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text("Alert"),
                                                content: Text(
                                                    "You have to enrolled "),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () => Navigator
                                                            .of(context)
                                                        .pop(), // Close the dialog
                                                    child: const Text("OK"),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } else {
                                          PaymentDialog.show(
                                            context: context,
                                            title: "Test payment process",
                                            buttonText: "Proceed to Pay",
                                            minAmount: 10,
                                            amount: amount,
                                            onConfirm: (upi, amount) async {
                                              final now = Timestamp.now();
                                              final userDocSnap =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('students')
                                                      .doc(_uid)
                                                      .get();
                                              final userDoc =
                                                  userDocSnap.data() ?? {};
                                              final paymentId =
                                                  FirebaseFirestore.instance
                                                      .collection('payments')
                                                      .doc()
                                                      .id;

                                              await FirebaseFirestore.instance
                                                  .collection('payments')
                                                  .doc(paymentId)
                                                  .set({
                                                'paymentId': paymentId,
                                                'studentUid': _uid,
                                                'studentName':
                                                    userDoc['name'] ?? '',
                                                'amount': amount,
                                                'testId': doc.id,
                                                'testTitle':
                                                    data['title'] ?? '',
                                                'paidAt': now,
                                                'upiId': upi,
                                                'status': 'success'
                                              });

                                              await FirebaseFirestore.instance
                                                  .collection('quizzes')
                                                  .doc(doc.id)
                                                  .collection(
                                                      'enrolledStudents')
                                                  .doc(_uid!)
                                                  .set({
                                                'uid': _uid!,
                                                'enrolledAt': now,
                                                'hasPaid': true,
                                                'paymentId': paymentId,
                                                'status': 'enrolled',
                                                'name': userDoc['name'] ?? '',
                                              });

                                              await FirebaseFirestore.instance
                                                  .collection('students')
                                                  .doc(_uid!)
                                                  .collection('enrolledTests')
                                                  .doc(doc.id)
                                                  .set({
                                                'testId': doc.id,
                                                'title': data['title'] ?? '',
                                                'fee': amount,
                                                'hasPaid': true,
                                                'enrolledAt': now,
                                                'status': 'enrolled',
                                                'testDateTime':
                                                    data['testDateTime'],
                                                'createdBy':
                                                    data['createdBy'] ?? '',
                                                'paymentId': paymentId,
                                              });

                                              setState(() {});
                                            },
                                          );
                                        }
                                      },
                                    ),
                                    if (isLive)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.red,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: const Text(
                                            'LIVE',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(filters.length, (index) {
            final isSelected = selectedFilter == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(filters[index]),
                selected: isSelected,
                selectedColor: Colors.deepPurple,
                backgroundColor: Theme.of(context).colorScheme.surface,
                labelStyle: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodySmall?.color,
                ),
                onSelected: (_) => setState(() => selectedFilter = index),
              ),
            );
          }),
        ),
      ),
    );
  }
}
