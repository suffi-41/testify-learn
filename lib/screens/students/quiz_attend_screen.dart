import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/loacl_storage.dart';
import '../../utils/helpers.dart';

class QuizAttendScreen extends StatefulWidget {
  final String quizId;
  final String title;
  final int durationInMinutes;

  const QuizAttendScreen({
    super.key,
    required this.quizId,
    required this.title,
    required this.durationInMinutes,
  });

  @override
  State<QuizAttendScreen> createState() => _QuizAttendScreenState();
}

class _QuizAttendScreenState extends State<QuizAttendScreen> {
  final PageController _pageController = PageController();
  List<Map<String, dynamic>> questions = [];
  Map<String, String> selectedAnswers = {};
  bool loading = true;
  int currentIndex = 0;

  late Duration totalDuration;
  late Duration remainingTime;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    totalDuration = Duration(minutes: widget.durationInMinutes);
    remainingTime = totalDuration;
    _startTimer();
    _loadQuestions();
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (remainingTime.inSeconds > 0) {
          remainingTime -= const Duration(seconds: 1);
        } else {
          timer.cancel();
          _submitQuiz(auto: true);
        }
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(widget.quizId)
        .collection('questions')
        .get();

    setState(() {
      questions =
          snapshot.docs.map((doc) => {"id": doc.id, ...doc.data()}).toList();
      loading = false;
    });
  }

  void _selectOption(String questionId, String option) {
    setState(() {
      selectedAnswers[questionId] = option;
    });
  }

  Future<void> _submitQuiz({bool auto = false}) async {
    timer.cancel();

    final uid = await getLoacalStorage("uid");
    int score = 0;

    for (var q in questions) {
      final correct = q["correctAnswer"] ?? '';
      final selected = selectedAnswers[q["id"]] ?? '';
      if (selected == correct) score++;
    }

    await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(widget.quizId)
        .collection('submissions')
        .doc(uid)
        .set({
      "selectedAnswers": selectedAnswers,
      "score": score,
      "timeTaken": totalDuration.inSeconds - remainingTime.inSeconds,
      "title": widget.title,
      "duration": widget.durationInMinutes,
    });

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(auto ? "Time's Up!" : "Quiz Submitted"),
        content: Text("Score: $score / ${questions.length}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentQ = questions[currentIndex];
    final options = List<String>.from(currentQ["options"] ?? []);
    final selected = selectedAnswers[currentQ["id"]] ?? '';
    final attempted = selectedAnswers.length;

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: UiHelpers.customAppBarForScreen(
          context,
          widget.title,
          actions: [
            Row(
              children: [
                const Icon(Icons.timer, size: 20, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  _formatTime(remainingTime),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
                const SizedBox(width: 12),
                if (selectedAnswers.length == questions.length)
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Confirm Submission"),
                          content:
                              const Text("Are you sure you want to submit?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _submitQuiz();
                              },
                              child: const Text("Submit"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text("Submit",
                        style: TextStyle(color: Colors.white)),
                  ),
              ],
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (currentIndex + 1) / questions.length,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
                minHeight: 6,
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Attempted: $attempted / ${questions.length}"),
                    Text("Q: ${currentIndex + 1}/${questions.length}"),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Q${currentIndex + 1}. ${currentQ["questionText"]}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...options.map((opt) {
                        final isSelected = selected == opt;
                        return GestureDetector(
                          onTap: () => _selectOption(currentQ["id"], opt),
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.deepPurple.shade100
                                  : Colors.white,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.deepPurple
                                    : Colors.grey.shade400,
                                width: 1.5,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isSelected
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  color: isSelected
                                      ? Colors.deepPurple
                                      : Colors.grey,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    opt,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.deepPurple
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 30),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (currentIndex > 0)
                            ElevatedButton(
                              onPressed: () {
                                setState(() => currentIndex--);
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              },
                              child: const Text("Previous"),
                            ),
                          if (currentIndex < questions.length - 1)
                            ElevatedButton(
                              onPressed: () {
                                setState(() => currentIndex++);
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.ease,
                                );
                              },
                              child: const Text("Next"),
                            ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
