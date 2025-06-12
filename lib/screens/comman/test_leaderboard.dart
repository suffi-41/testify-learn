import 'package:flutter/material.dart';
import '../../utils/responsive.dart';
import '../../utils/helpers.dart';
import '../../widgets/score_tile.dart';

class TestLeaderboardScreen extends StatefulWidget {
  final String testId;
  const TestLeaderboardScreen({super.key, required this.testId});

  @override
  State<TestLeaderboardScreen> createState() => _TestLeaderboardScreenState();
}

class _TestLeaderboardScreenState extends State<TestLeaderboardScreen> {
  final Map<String, String> testTitles = {
    "math-x": "Mathematics Test (X)",
    "sci-xi": "Science Quiz (XI)",
    "hist-ix": "History Test (IX)",
    "eng-xii": "English Grammar (XII)",
  };

  final Map<String, Map<String, String>> testDetails = {
    "math-x": {"date": "12-06-2025", "time": "4:30 PM"},
    "sci-xi": {"date": "15-06-2025", "time": "2:00 PM"},
    "hist-ix": {"date": "18-06-2025", "time": "10:00 AM"},
    "eng-xii": {"date": "20-06-2025", "time": "1:00 PM"},
  };

  final Map<String, List<Map<String, dynamic>>> testLeaderboards = {
    "math-x": List.generate(6, (index) {
      return {
        'rank': index + 1,
        'name': index == 0 ? 'Mohd Affan' : 'Sara Zain',
        'subject': 'Math',
        'score': 500 - (index * 10),
        'time': '5 min ${30 + index} sec',
        'reward': 250 - (index * 10),
      };
    }),
    "sci-xi": [
      {
        'rank': 1,
        'name': 'Ali Khan',
        'subject': 'Science',
        'score': 490,
        'time': '6 min',
        'reward': 200,
      },
    ],
    "hist-ix": [
      {
        'rank': 1,
        'name': 'Riya Sen',
        'subject': 'History',
        'score': 480,
        'time': '7 min',
        'reward': 180,
      },
    ],
    "eng-xii": [
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
    final title = testTitles[widget.testId] ?? "Leaderboard";
    final date = testDetails[widget.testId]?['date'] ?? "-";
    final time = testDetails[widget.testId]?['time'] ?? "-";

    return Scaffold(
      appBar: UiHelpers.customAppBarForScreen(
        context,
        title,
        automaticallyImplyLeading: true,
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
    final leaderboard = testLeaderboards[widget.testId] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: leaderboard.isEmpty
              ? const Center(child: Text("No data available"))
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: leaderboard.length,
                  itemBuilder: (context, index) {
                    final entry = leaderboard[index];
                    return ScoreTile(
                      rank: entry['rank'],
                      name: entry['name'],
                      score: entry['score'].toString(),
                      duration: entry['time'],
                      reward: entry['reward'].toString(),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
