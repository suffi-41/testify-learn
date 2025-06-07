import 'package:flutter/material.dart';

class QuizHeader extends StatelessWidget {
  final String title;
  final String totalDuration;
  final String timeTaken;
  final VoidCallback onTap;

  const QuizHeader({
    super.key,
    required this.title,
    required this.totalDuration,
    required this.timeTaken,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(
          Icons.assignment_turned_in,
          color: Colors.deepPurple,
          size: 32,
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text("Total Duration: $totalDuration"),
            Text("Time Taken: $timeTaken"),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
      ),
    );
  }
}
