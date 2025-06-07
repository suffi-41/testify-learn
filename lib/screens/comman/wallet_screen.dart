import 'package:flutter/material.dart';
import '../../widgets/sticky_widget.dart';
import '../../utils/helpers.dart';
import '../../widgets/transection_tile.dart';
import '../../widgets/payment_dialog.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int selectedFilter = 0;
  final List<String> filters = [
    'All',
    'Add Money',
    'Withdrawals',
    'Test Paid',
    'Rewards',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiHelpers.customAppBarForScreen(context, "Wallet"),
      body: CustomScrollView(
        slivers: [
          // Wallet Header
          SliverToBoxAdapter(child: _walletHeaderCard()),

          // Sticky Filter Bar
          StickyTopPositioned(child: _buildFilterChips(context)),

          // Transaction Title and List
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Transaction History",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => TransactionTile(
                title: filters[selectedFilter % filters.length],
                date: "12-06-2025",
                amount: "+₹${(index + 1) * 50}",
                status: "successful",
              ),
              childCount: 10,
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
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Available Balance",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 8),
              const Text(
                "₹500",
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _walletButton("Withdraw", Icons.money_off, Colors.white, () {
                    _showWithdrawDialog(context);
                  }),
                  const SizedBox(width: 12),
                  _walletButton("Add Money", Icons.add_card, Colors.white, () {
                    _showAddMoneyDialog(context);
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _walletButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: color),
        label: Text(label, style: TextStyle(color: color)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withOpacity(0.2),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: EdgeInsets.symmetric(horizontal: 20),
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
                      : Theme.of(context).textTheme.headlineMedium?.color,
                ),
                onSelected: (_) => setState(() => selectedFilter = index),
              ),
            );
          }),
        ),
      ),
    );
  }

  void _showAddMoneyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => PaymentDialog(
        title: "Add Money",
        buttonText: "Proceed to Pay",
        minAmount: 25,
        onConfirm: (upi, amount) {
          print("Add ₹$amount via $upi");
        },
      ),
    );
  }

  void _showWithdrawDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => PaymentDialog(
        title: "Withdraw",
        buttonText: "Request Withdrawal",
        minAmount: 50,
        onConfirm: (upi, amount) {
          print("Withdraw ₹$amount to $upi");
        },
      ),
    );
  }
}
