// improved_taken_test_review_screen.dart
import 'package:flutter/material.dart';
import '../../utils/helpers.dart';
import '../../widgets/quiz_header.dart';

class TakenTestReviewScreen extends StatefulWidget {
  const TakenTestReviewScreen({super.key});

  @override
  State<TakenTestReviewScreen> createState() => _TakenTestReviewScreenState();
}

class _TakenTestReviewScreenState extends State<TakenTestReviewScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, dynamic>> questions = const [
    {
      'question': "What is the Largest mammal in the world?",
      'options': ["African Elephant", "Blue Whale", "Giraffe", "Hippopotamus"],
      'correctAnswer': "Blue Whale",
      'selectedAnswer': "Giraffe",
    },
    {
      'question': "Which planet is known as the Red Planet?",
      'options': ["Earth", "Mars", "Venus", "Saturn"],
      'correctAnswer': "Mars",
      'selectedAnswer': "Mars",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentQuestion = questions[_currentIndex];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header without bottom radius
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple.shade400, Colors.deepPurple.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                // Removed borderRadius here
                // borderRadius: const BorderRadius.only(
                //   bottomLeft: Radius.circular(24),
                //   bottomRight: Radius.circular(24),
                // ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Mathematics Test (X)",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Icon(Icons.list_alt, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text("Questions: 2/30", style: TextStyle(color: Colors.white)),
                      SizedBox(width: 12),
                      Icon(Icons.access_time, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text("Time: 60 min", style: TextStyle(color: Colors.white)),
                      SizedBox(width: 12),
                      Icon(Icons.star, color: Colors.white, size: 20),
                      SizedBox(width: 6),
                      Text("Score: 60", style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.timer, color: Colors.deepPurple, size: 18),
                        SizedBox(width: 6),
                        Text("Time Taken: 40 min 35 sec",
                            style: TextStyle(color: Colors.deepPurple, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )
                ],
              ),
            ),

            // Progress Indicator
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              height: 6,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(30),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (_currentIndex + 1) / questions.length,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),

            // Question Display
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: questions.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => _buildQuestionCard(questions[index]),
              ),
            ),

            // Bottom Navigation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentIndex > 0)
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentIndex--;
                          _pageController.jumpToPage(_currentIndex);
                        });
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text("Previous"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.black87,
                      ),
                    )
                  else
                    const SizedBox(),

                  if (_currentIndex < questions.length - 1)
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          _currentIndex++;
                          _pageController.jumpToPage(_currentIndex);
                        });
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("Next"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                      ),
                    )
                  else
                    const SizedBox(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> q) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.deepPurple.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              q['question'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          ...q['options'].map<Widget>((opt) {
            bool isSelected = q['selectedAnswer'] == opt;
            bool isCorrect = q['correctAnswer'] == opt;
            Color? color;
            IconData? icon;

            if (isCorrect && isSelected) {
              color = Colors.green.shade300;
              icon = Icons.check_circle;
            } else if (isSelected && !isCorrect) {
              color = Colors.red.shade300;
              icon = Icons.cancel;
            } else if (!isSelected && isCorrect) {
              color = Colors.green.shade100;
              icon = Icons.check_circle_outline;
            } else {
              color = Colors.white;
            }

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(child: Text(opt)),
                  if (icon != null)
                    Icon(icon, color: isCorrect ? Colors.green : Colors.red),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
