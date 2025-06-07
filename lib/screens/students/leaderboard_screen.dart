import 'package:flutter/material.dart';
import '../../utils/responsive.dart'; // your responsive layout utility
import '../../utils/helpers.dart';
import '../../widgets/text_card.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  String selectedTest = "Mathematics Test (X)";

  final List<String> testOptions = [
    "Mathematics Test (X)",
    "Science Quiz (XI)",
    "History Test (IX)",
    "English Grammar (XII)",
  ];

  final Map<String, List<Map<String, dynamic>>> testLeaderboards = {
    "Mathematics Test (X)": [
      {
        'rank': 1,
        'name': 'Mohd Affan',
        'subject': 'Math',
        'score': 500,
        'time': '5 min 30 sec',
        'reward': 250,
      },
      {
        'rank': 2,
        'name': 'Sara Zain',
        'subject': 'Math',
        'score': 470,
        'time': '6 min 12 sec',
        'reward': 200,
      },
    ],
    "Science Quiz (XI)": [
      {
        'rank': 1,
        'name': 'Ali Khan',
        'subject': 'Science',
        'score': 490,
        'time': '6 min',
        'reward': 200,
      },
    ],
    "History Test (IX)": [
      {
        'rank': 1,
        'name': 'Riya Sen',
        'subject': 'History',
        'score': 480,
        'time': '7 min',
        'reward': 180,
      },
    ],
    "English Grammar (XII)": [
      {
        'rank': 1,
        'name': 'John Deo',
        'subject': 'English',
        'score': 495,
        'time': '5 min 10 sec',
        'reward': 200,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiHelpers.customAppBarForScreen(
        context,
        "Leaderboard",
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                value: selectedTest,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                items: testOptions.map((value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child:  TestCard(),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedTest = value;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: ResponsiveLayout(
        mobile: _buildBody(context),
        tablet: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: _buildBody(context),
          ),
        ),
        desktop: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _buildBody(context),
          ),
        ),
        largeDesttop: Row(
          children: [
            Expanded(flex: 2, child: _buildBody(context)),
            const VerticalDivider(width: 1),
            const Expanded(child: Center(child: Text("Extra Panel"))),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final leaderboard = testLeaderboards[selectedTest] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: leaderboard.isEmpty
              ? const Center(child: Text("No data available"))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) =>
                      _buildLeaderboardCard(leaderboard[index]),
                ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardCard(Map<String, dynamic> data) {
    final int rank = data['rank'];

    Color getRankColor(int rank) {
      switch (rank) {
        case 1:
          return Colors.amber;
        case 2:
          return Colors.grey;
        case 3:
          return Colors.brown;
        default:
          return Colors.deepPurple;
      }
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: getRankColor(rank),
              child: Text(
                rank.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data['name'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Subject: ${data['subject']}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.score, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text("Score: ${data['score']}"),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      size: 18,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "₹${data['reward']}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      data['time'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
