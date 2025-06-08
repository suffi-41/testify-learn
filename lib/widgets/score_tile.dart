import 'package:flutter/material.dart';

class ScoreTile extends StatelessWidget {
  final int rank;
  final String name;
  final String score;
  final String duration;
  final String reward;

  const ScoreTile({
    super.key,
    required this.rank,
    required this.name,
    required this.score,
    required this.duration,
    required this.reward,
  });

  Color getRankColor(BuildContext context, int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey;
      case 3:
        return Colors.brown;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface, // light purple
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Side: Rank and Name + Score
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: getRankColor(context, rank),
                child: Text(
                  rank.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: Theme.of(context).textTheme.titleMedium),
                  Text(
                    'Scores: $score',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),

          // Right Side: Reward and Time
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('₹$reward', style: Theme.of(context).textTheme.titleMedium),
              Text(duration, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
