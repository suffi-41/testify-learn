import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../widgets/sticky_widget.dart';
import "../../widgets/transecction_tile.dart";
import '../../widgets/payment_dialog.dart';
import '../../utils/helpers.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int selectedFilter = 0;
  bool _isProcessing = false;

  final List<String> filters = [
    'All',
    'Add Money',
    'Withdrawals',
    'Test Paid',
    'Rewards',
  ];

  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiHelpers.customAppBarForScreen(context, "Wallet"),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _walletHeaderCard()),
              StickyTopPositioned(child: _buildFilterChips()),
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Transaction History",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _buildTransactionList()),
            ],
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _walletHeaderCard() {
    return Align(
      alignment: Alignment.topLeft,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7B61FF), Color(0xFF9C4DFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Available Balance",
                  style: TextStyle(color: Colors.white)),
              const SizedBox(height: 8),
              StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('wallets')
                    .doc(userId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Text("₹...",
                        style: TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold));
                  }
                  if (!snapshot.hasData || !snapshot.data!.exists) {
                    return const Text("₹0",
                        style: TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold));
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  final balance = data['balance'] ?? 0;

                  return Text(
                    "₹$balance",
                    style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _walletButton("Withdraw", Icons.money_off, Colors.white, () {
                    PaymentDialog.show(
                      context: context,
                      title: "Withdraw",
                      buttonText: "Request Withdrawal",
                      minAmount: 50,
                      onConfirm: (upi, amount) async {
                        setState(() => _isProcessing = true);
                        try {
                          await _handleTransaction(
                            amount: amount.toInt(),
                            upi: upi,
                            type: "Withdrawals",
                            isAddition: false,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: ${e.toString()}")),
                          );
                        }
                        setState(() => _isProcessing = false);
                      },
                    );
                  }),
                  const SizedBox(width: 12),
                  _walletButton("Add Money", Icons.add_card, Colors.white, () {
                    PaymentDialog.show(
                      context: context,
                      title: "Add Money",
                      buttonText: "Proceed to Pay",
                      minAmount: 15,
                      onConfirm: (upi, amount) async {
                        setState(() => _isProcessing = true);
                        try {
                          await _handleTransaction(
                            amount: amount.toInt(),
                            upi: upi,
                            type: "Add Money",
                            isAddition: true,
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: ${e.toString()}")),
                          );
                        }
                        setState(() => _isProcessing = false);
                      },
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleTransaction({
    required int amount,
    required String upi,
    required String type,
    required bool isAddition,
  }) async {
    final walletRef =
        FirebaseFirestore.instance.collection('wallets').doc(userId);
    final userTxnRef = walletRef.collection('transactions').doc();
    final globalTxnRef =
        FirebaseFirestore.instance.collection('payments').doc();

    await FirebaseFirestore.instance.runTransaction((txn) async {
      final walletSnap = await txn.get(walletRef);
      int currentBalance =
          walletSnap.exists ? (walletSnap.data()?['balance'] ?? 0) : 0;

      if (!isAddition && currentBalance < amount) {
        throw Exception("Insufficient balance");
      }

      int updatedBalance =
          isAddition ? currentBalance + amount : currentBalance - amount;

      txn.set(walletRef, {'balance': updatedBalance}, SetOptions(merge: true));

      final txnData = {
        'userId': userId,
        'amount': amount,
        'type': type,
        'status': 'Successful',
        'upi': upi,
        'date': Timestamp.now(),
      };

      txn.set(userTxnRef, txnData);
      txn.set(globalTxnRef, txnData);
    });
  }

  Widget _walletButton(
      String label, IconData icon, Color color, VoidCallback onPressed) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        label: Text(label, style: TextStyle(color: color)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
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
                      : Theme.of(context).textTheme.bodyLarge?.color,
                ),
                onSelected: (_) => setState(() => selectedFilter = index),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    Query transactionsQuery = FirebaseFirestore.instance
        .collection('wallets')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true);

    if (filters[selectedFilter] != 'All') {
      transactionsQuery =
          transactionsQuery.where('type', isEqualTo: filters[selectedFilter]);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: transactionsQuery.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(32.0),
            child: Center(child: Text("No transactions found.")),
          );
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data() as Map<String, dynamic>;
            final timestamp = data['date'] as Timestamp;
            final date =
                "${timestamp.toDate().day}-${timestamp.toDate().month}-${timestamp.toDate().year}";

            return TransactionTile(
              title: data['type'] ?? 'Unknown',
              date: date,
              amount: "₹${data['amount']}",
              status: data['status'] ?? 'Unknown',
            );
          },
        );
      },
    );
  }
}
