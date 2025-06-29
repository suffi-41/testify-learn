import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../widgets/tests_card_widget.dart';
import '../../utils/helpers.dart';
import '../../constants/app_routes.dart';
import '../../utils/loacl_storage.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _selectedFilter = 0;
  String? _coachingCode;
  String? _uid;
  bool _isLoading = true;

  final List<String> _filters = [
    'All',
    'Upcoming',
    'Live',
    'Enrolled',
    'Completed'
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
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
                  child: _buildTestList(),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      alignment: Alignment.topLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _filters
              .asMap()
              .entries
              .map((entry) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(entry.value),
                      selected: _selectedFilter == entry.key,
                      selectedColor: Colors.deepPurple,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      labelStyle: TextStyle(
                        color: _selectedFilter == entry.key
                            ? Colors.white
                            : Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      onSelected: (_) =>
                          setState(() => _selectedFilter = entry.key),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }

  Widget _buildTestList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('quizzes')
          .where('coachingCode', isEqualTo: _coachingCode)
          .where('isPublished', isEqualTo: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No tests available'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, i) {
            final doc = snapshot.data!.docs[i];
            return _TestItem(
              doc: doc,
              uid: _uid!,
              selectedFilter: _selectedFilter,
              coachingCode: _coachingCode!,
            );
          },
        );
      },
    );
  }
}

class _TestItem extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  final String uid;
  final int selectedFilter;
  final String coachingCode;

  const _TestItem({
    required this.doc,
    required this.uid,
    required this.selectedFilter,
    required this.coachingCode,
  });

  @override
  State<_TestItem> createState() => __TestItemState();
}

class __TestItemState extends State<_TestItem> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final data = widget.doc.data() as Map<String, dynamic>;
    final testId = widget.doc.id;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('quizzes')
          .doc(testId)
          .collection('enrolledStudents')
          .doc(widget.uid)
          .snapshots(),
      builder: (context, enrolledSnapshot) {
        if (!enrolledSnapshot.hasData) return const SizedBox.shrink();

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('quizzes')
              .doc(testId)
              .collection('enrolledStudents')
              .snapshots(),
          builder: (context, countSnapshot) {
            if (!countSnapshot.hasData) return const SizedBox.shrink();

            return _buildTestCard(
              data: data,
              testId: testId,
              enrolledData:
                  enrolledSnapshot.data!.data() as Map<String, dynamic>?,
              enrolledCount: countSnapshot.data!.size,
            );
          },
        );
      },
    );
  }

  Widget _buildTestCard({
    required Map<String, dynamic> data,
    required String testId,
    required Map<String, dynamic>? enrolledData,
    required int enrolledCount,
  }) {
    final testStatus =
        (data['status'] ?? 'upcoming').toString().trim().toLowerCase();
    final fee =
        int.tryParse(data['fee']?.toString().replaceAll('₹', '') ?? '0') ?? 0;
    final isPaid = enrolledData?['hasPaid'] ?? false;

    // Apply filter
    if (_shouldSkipCard(testStatus, isPaid)) {
      return const SizedBox.shrink();
    }

    final testStartTime = data['testDateTime'];
    // final datePart = testStartTime != null
    //     ? DateFormat("dd-MM-yyyy").format(testStartTime)
    //     : 'Unknown';
    // final timePart = testStartTime != null
    //     ? DateFormat("h:mm a").format(testStartTime)
    //     : 'Unknown';

    final cardInfo = _getCardInfo(testStatus, isPaid, fee, context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          // Test Card with disabled interaction during processing
          AbsorbPointer(
            absorbing: _isProcessing,
            child: TestCard(
              subject: data['title'] ?? 'Untitled Test',
              date: testStartTime?.split(' ')[0],
              time:
                  '${testStartTime?.split(' ')[1]} ${testStartTime?.split(' ')[2]}',
              duration: data['duration'] ?? 'Unknown',
              mcqCount: data['totalQuestions']?.toString() ?? '0',
              status: cardInfo.statusLabel,
              actionLabel: cardInfo.actionLabel,
              actionColor: cardInfo.statusColor,
              extraInfo: 'Enrolled: $enrolledCount students',
              onPressed: () => _handleCardAction(
                testStatus: testStatus,
                isPaid: isPaid,
                fee: fee,
                testId: testId,
                data: data,
              ),
            ),
          ),

          // LIVE badge
          if (testStatus == 'live')
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(12),
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

          // Processing overlay
          if (_isProcessing)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _shouldSkipCard(String testStatus, bool isPaid) {
    return widget.selectedFilter != 0 &&
        ((widget.selectedFilter == 1 && testStatus != 'upcoming') ||
            (widget.selectedFilter == 2 && testStatus != 'live') ||
            (widget.selectedFilter == 3 && !isPaid) ||
            (widget.selectedFilter == 4 && testStatus != 'completed'));
  }

  DateTime? _parseTestTime(dynamic testTime) {
    return testTime is Timestamp ? testTime.toDate() : null;
  }

  _CardInfo _getCardInfo(
    String testStatus,
    bool isPaid,
    int fee,
    BuildContext context,
  ) {
    String statusLabel = 'Upcoming';
    Color statusColor = Theme.of(context).colorScheme.secondary;
    String actionLabel = '₹$fee';

    if (testStatus == 'live') {
      statusLabel = 'Live';
      statusColor = Theme.of(context).colorScheme.primary;
      actionLabel = isPaid ? 'Join Now' : '₹$fee';
    } else if (testStatus == 'completed') {
      statusLabel = 'Completed';
      statusColor = Colors.grey;
      actionLabel = isPaid ? 'Leaderboard' : '₹$fee';
    } else if (isPaid) {
      statusLabel = 'Enrolled';
      actionLabel = 'Enrolled';
      statusColor = Theme.of(context).colorScheme.primary;
    }

    return _CardInfo(statusLabel, actionLabel, statusColor);
  }

  Future<void> _handleCardAction({
    required String testStatus,
    required bool isPaid,
    required int fee,
    required String testId,
    required Map<String, dynamic> data,
  }) async {
    // Live test - paid user
    if (testStatus == 'live' && isPaid) {
      if (context.mounted) {
        context.go(
          '${AppRoutes.takeTest}/$testId',
        );
      }
      return;
    }

    // Completed test - paid user
    if (testStatus == 'completed' && isPaid) {
      if (context.mounted) {
        context.push('${AppRoutes.testLeaderborad}/$testId');
      }
      return;
    }

    // Unpaid user flow
    if (!isPaid) {
      await _handlePayment(fee: fee, testId: testId, data: data);
    }
  }

  Future<void> _handlePayment({
    required int fee,
    required String testId,
    required Map<String, dynamic> data,
  }) async {
    setState(() => _isProcessing = true);

    final walletRef =
        FirebaseFirestore.instance.collection('wallets').doc(widget.uid);
    final walletSnap = await walletRef.get();
    final walletBalance = walletSnap.data()?['balance'] ?? 0;

    if (walletBalance < fee) {
      setState(() => _isProcessing = false);
      if (!context.mounted) return;
      await _showInsufficientBalanceDialog(fee, walletBalance);
      return;
    }

    final confirm = await _showPaymentConfirmationDialog(fee);
    if (confirm != true) {
      setState(() => _isProcessing = false);
      return;
    }

    await _processPayment(
      fee: fee,
      testId: testId,
      data: data,
      walletBalance: walletBalance,
      walletRef: walletRef,
    );

    setState(() => _isProcessing = false);
  }

  Future<void> _showInsufficientBalanceDialog(
      int fee, int walletBalance) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Insufficient Wallet Balance"),
        content: Text(
          "You need ₹$fee but only ₹$walletBalance is available.\nPlease recharge your wallet.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.studentWallet);
            },
            child: const Text("Add Money"),
          ),
        ],
      ),
    );
  }

  Future<bool?> _showPaymentConfirmationDialog(int fee) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Payment'),
        content: Text('Do you want to pay ₹$fee for this test?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Confirm"),
          ),
        ],
      ),
    );
  }

  Future<void> _processPayment({
    required int fee,
    required String testId,
    required Map<String, dynamic> data,
    required int walletBalance,
    required DocumentReference walletRef,
  }) async {
    final now = Timestamp.now();
    final txnRef = walletRef.collection('transactions').doc();
    final paymentRef = FirebaseFirestore.instance.collection('payments').doc();
    final studentRef =
        FirebaseFirestore.instance.collection('students').doc(widget.uid);
    final enrolledRef = FirebaseFirestore.instance
        .collection('quizzes')
        .doc(testId)
        .collection('enrolledStudents')
        .doc(widget.uid);
    final studentTestRef = studentRef.collection('enrolledTests').doc(testId);

    final studentData = (await studentRef.get()).data() ?? {};

    await FirebaseFirestore.instance.runTransaction((txn) async {
      txn.update(walletRef, {
        'balance': walletBalance - fee,
        'updatedAt': now,
      });

      txn.set(txnRef, {
        'testId': testId,
        'amount': fee,
        'type': 'Test Paid',
        'status': 'Successful',
        'upi': "Wallet",
        'note': 'Test payment for ${data['title']}',
        'date': now,
      });

      txn.set(paymentRef, {
        'paymentId': paymentRef.id,
        'studentUid': widget.uid,
        'studentName': studentData['name'] ?? '',
        'amount': fee,
        'testId': testId,
        'testTitle': data['title'] ?? '',
        'paidAt': now,
        'upiId': 'wallet',
        'status': 'success',
      });

      txn.set(enrolledRef, {
        'uid': widget.uid,
        'enrolledAt': now,
        'isPresent': false,
        'hasPaid': true,
        'paymentId': paymentRef.id,
        'status': 'enrolled',
        'name': studentData['name'] ?? '',
      });

      txn.set(studentTestRef, {
        'testId': testId,
        'title': data['title'] ?? '',
        'fee': fee,
        'hasPaid': true,
        'enrolledAt': now,
        'status': 'enrolled',
        'testDateTime': data['testDateTime'],
        'createdBy': data['createdBy'] ?? '',
        'paymentId': paymentRef.id,
      });
    });
  }
}

class _CardInfo {
  final String statusLabel;
  final String actionLabel;
  final Color statusColor;

  _CardInfo(this.statusLabel, this.actionLabel, this.statusColor);
}
