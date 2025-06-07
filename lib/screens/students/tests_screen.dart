import 'package:flutter/material.dart';
import '../../widgets/tests_card_widget.dart';
import '../../utils/helpers.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int selectedFilter = 0;
  final filters = ['All', 'Upcoming', 'Completed'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiHelpers.customAppBarForScreen(context, "Tests"),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: List.generate(10, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TestCard(
                      subject: "Mathematics Test (X)",
                      date: "12-06-2025",
                      time: "4:30 PM",
                      duration: "60 min",
                      mcqCount: "30",
                      status: index % 2 == 0 ? "Upcoming" : "Completed",
                      actionLabel: index % 2 == 0 ? "₹50" : "Leaderboard",
                      actionColor: index % 2 == 0
                          ? Colors.green
                          : Theme.of(context).colorScheme.primary,
                    ),
                  );
                }),
              ),
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
                  color: Theme.of(context).textTheme.bodySmall!.color,
                ),
                onSelected: (_) {
                  setState(() {
                    selectedFilter = index;
                  });
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
