import 'package:flutter/material.dart';

class ScoreList extends StatelessWidget {
  final int rank;
  final String name;
  final String score;
  final String reward;
  final String duration;

  const ScoreList({
    super.key,
    required this.rank,
    required this.name,
    required this.score,
    required this.reward,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    Color getRankColor(int rank) {
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
                backgroundColor: getRankColor(rank),
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
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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

              Text(
                duration,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
