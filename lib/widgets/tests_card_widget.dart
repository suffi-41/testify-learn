import 'package:flutter/material.dart';

class TestCard extends StatelessWidget {
  final String subject;
  final String date;
  final String time;
  final String duration;
  final String mcqCount;
  final String status;
  final String actionLabel;
  final Color actionColor;
  final VoidCallback onPressed;

  const TestCard({
    super.key,
    required this.subject,
    required this.date,
    required this.time,
    required this.duration,
    required this.mcqCount,
    required this.status,
    required this.actionLabel,
    required this.actionColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                subject,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).textTheme.titleSmall?.color?.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(status, style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Date & Time
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16),
              const SizedBox(width: 4),
              Text("Date: $date"),
              const SizedBox(width: 12),
              const Icon(Icons.access_time, size: 16),
              const SizedBox(width: 4),
              Text("Time: $time"),
            ],
          ),
          const SizedBox(height: 12),

          // Duration, MCQs, Button
          Row(
            children: [
              const Icon(Icons.timer, size: 18),
              const SizedBox(width: 4),
              Text(duration),
              const SizedBox(width: 12),
              const Icon(Icons.description, size: 18),
              const SizedBox(width: 4),
              Text("$mcqCount MCQ"),
              const Spacer(),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: actionColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(actionLabel),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
