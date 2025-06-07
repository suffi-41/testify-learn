import 'package:flutter/material.dart';
import '../../utils/responsive.dart';
import '../../utils/helpers.dart';
import '../../widgets/score_list.dart';

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

  final Map<String, Map<String, String>> testDetails = {
    "Mathematics Test (X)": {"date": "12-06-2025", "time": "4:30 PM"},
    "Science Quiz (XI)": {"date": "15-06-2025", "time": "2:00 PM"},
    "History Test (IX)": {"date": "18-06-2025", "time": "10:00 AM"},
    "English Grammar (XII)": {"date": "20-06-2025", "time": "1:00 PM"},
  };

  final Map<String, List<Map<String, dynamic>>> testLeaderboards = {
    "Mathematics Test (X)": List.generate(6, (index) {
      return {
        'rank': index + 1,
        'name': index == 0 ? 'Mohd Affan' : 'Sara Zain',
        'subject': 'Math',
        'score': 500 - (index * 10),
        'time': '5 min ${30 + index} sec',
        'reward': 250 - (index * 10),
      };
    }),
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
                value: selectedTest,
                dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                selectedItemBuilder: (context) {
                  return testOptions.map((value) {
                    return Align(
                      alignment: Alignment.center,
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList();
                },
                items: testOptions.map((value) {
                  final details =
                      testDetails[value] ?? {"date": "-", "time": "-"};
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      "$value\nDate: ${details["date"]}\nTime: ${details["time"]}",
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
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

        Expanded(
          child: leaderboard.isEmpty
              ? const Center(child: Text("No data available"))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: 20,
                  itemBuilder: (context, index) => ScoreList(
                    rank: index + 1,
                    name: "Sufiyan",
                    score: "95",
                    reward: "1500",
                    duration: "2h 30m",
                  ),
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE4F4), // light purple
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
                  Text(
                    data['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    'Scores: ${data['score']}',
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
              Text(
                '₹${data['reward']}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Text(
                data['time'],
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
