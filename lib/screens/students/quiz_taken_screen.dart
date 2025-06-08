import 'package:flutter/material.dart';
import '../../utils/responsive.dart';

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
    {
      'question': "Which planet is known as the Red Planet?",
      'options': ["Earth", "Mars", "Venus", "Saturn"],
      'correctAnswer': "Mars",
      'selectedAnswer': "Mars",
    },
  ];

  Widget _buildQuestionCard(Map<String, dynamic> questionData) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              Text(
                questionData['question'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ...questionData['options'].map<Widget>((opt) {
                final bool isCorrect = opt == questionData['correctAnswer'];
                final bool isSelected = opt == questionData['selectedAnswer'];

                IconData? icon;
                Color? color;

                if (isCorrect && isSelected) {
                  icon = Icons.check_circle;
                  color = Colors.green;
                } else if (isSelected && !isCorrect) {
                  icon = Icons.cancel;
                  color = Colors.red;
                } else if (isCorrect) {
                  icon = Icons.check_circle_outline;
                  color = Colors.green;
                }

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: color ?? Colors.grey.shade400,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        opt,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: color ?? Colors.black,
                        ),
                      ),
                      if (icon != null) Icon(icon, color: color),
                    ],
                  ),
                );
              }).toList(),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentIndex > 0)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex--;
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        });
                      },
                      child: const Text("Previous"),
                    ),
                  if (_currentIndex < questions.length - 1)
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentIndex++;
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        });
                      },
                      child: const Text("Next"),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ✅ Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade400,
                    Colors.deepPurple.shade700,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
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
                          Row(
                            children: [
                              Icon(Icons.list_alt, color: Colors.white, size: 20),
                              SizedBox(width: 6),
                              Text("Questions: 1/30", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.access_time, color: Colors.white, size: 20),
                              SizedBox(width: 6),
                              Text("Time: 60 min", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.white, size: 20),
                              SizedBox(width: 6),
                              Text("Score: 60", style: TextStyle(color: Colors.white)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer, color: Colors.deepPurple, size: 18),
                            SizedBox(width: 6),
                            Text(
                              "Time Taken: 40 min 35 sec",
                              style: TextStyle(
                                color: Colors.deepPurple,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: questions.length,
                itemBuilder: (context, index) {
                  return _buildQuestionCard(questions[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
