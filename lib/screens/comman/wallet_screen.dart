import 'package:flutter/material.dart';
import '../../utils/helpers.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  int selectedFilter = 0;
  final filters = ['All', 'Add money', 'Withdrawals', 'Test Paid', 'Rewards'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiHelpers.customAppBarForScreen(context, "Wallets"),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxScrolled) => [
            SliverToBoxAdapter(child: _walletHeaderCard()),

            // Sticky Filter Row
            SliverPersistentHeader(
              pinned: true,
              delegate: _StickyFilterHeader(child: _buildFilterChips()),
            ),

            // Optional Title Below Filter
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Transaction History",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ],
          body: ListView.builder(
            padding: const EdgeInsets.only(bottom: 16),
            itemCount: 20,
            itemBuilder: (context, index) {
              return _transactionTile(
                icon: Icons.account_balance_wallet,
                title: "Add Money",
                date: "12-06-2025",
                amount: "+₹100",
                status: "Successful",
                color: Colors.green,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _walletHeaderCard() {
    return Container(
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
              _walletButton("Withdraw", Icons.money_off, Colors.white),
              const SizedBox(width: 12),
              _walletButton("Add Money", Icons.add_card, Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      color: Colors.white,
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
                backgroundColor: Colors.grey.shade200,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black,
                ),
                onSelected: (_) => setState(() => selectedFilter = index),
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _walletButton(String label, IconData icon, Color color) {
    return Expanded(
      child: ElevatedButton.icon(
        onPressed: () {},
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

  Widget _transactionTile({
    required IconData icon,
    required String title,
    required String date,
    required String amount,
    required Color color,
    String? status,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepPurple.shade100),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.deepPurple.shade100,
            child: Icon(icon, color: Colors.deepPurple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(date, style: const TextStyle(color: Colors.grey)),
                if (status != null)
                  Text(
                    status,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// Sticky Header Delegate
class _StickyFilterHeader extends SliverPersistentHeaderDelegate {
  final Widget child;
  _StickyFilterHeader({required this.child});

  @override
  double get minExtent => 60;
  @override
  double get maxExtent => 60;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return child;
  }

  @override
  bool shouldRebuild(covariant _StickyFilterHeader oldDelegate) {
    return child != oldDelegate.child;
  }
}
