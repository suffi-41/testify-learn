import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/loacl_storage.dart';
import '../../utils/helpers.dart';

class QuizAttendScreen extends StatefulWidget {
  final String quizId;

  const QuizAttendScreen({super.key, required this.quizId});

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
  Duration remainingTime = Duration.zero;
  Timer? timer;
  bool _isSubmitted = false;

  String title = "";
  int durationInMinutes = 0;
  bool isQuizDataLoading = true;
  DateTime? quizEndTime;

  @override
  void initState() {
    super.initState();
    _loadQuizMetaAndProceed();
  }

  Future<void> _loadQuizMetaAndProceed() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .get();

      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Quiz not found")),
        );
        return;
      }

      final data = doc.data()!;
      title = data['title'] ?? "Quiz";

      final rawDuration = data['duration'];
      if (rawDuration is int) {
        durationInMinutes = rawDuration;
      } else if (rawDuration is String) {
        durationInMinutes =
            int.tryParse(rawDuration.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
      }
      if (durationInMinutes == 0) throw Exception("Invalid duration");

      final startRaw = data['testDateTime'];
      if (startRaw == null) throw Exception("Quiz has no start time");

      DateTime start;
      if (startRaw is Timestamp) {
        start = startRaw.toDate();
      } else if (startRaw is String) {
        start = DateTime.tryParse(startRaw) ?? DateTime.now();
      } else {
        throw Exception("Invalid format for testDateTime");
      }

      final now = DateTime.now();
      quizEndTime = start.add(Duration(minutes: durationInMinutes));

      if (now.isBefore(start)) {
        final waitTime = start.difference(now);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Quiz will start in ${_formatTime(waitTime)}")),
        );
        setState(() => isQuizDataLoading = false);
        return;
      }

      totalDuration = Duration(minutes: durationInMinutes);
      remainingTime = quizEndTime!.difference(now);

      if (remainingTime.inSeconds <= 0) {
        remainingTime = Duration.zero;
        Future.delayed(Duration.zero, () => _submitQuiz(auto: true));
        return;
      }

      _checkAlreadySubmitted();
      _startTimer();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading quiz: $e")),
      );
    } finally {
      setState(() => isQuizDataLoading = false);
    }
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    final now = DateTime.now();
    if (quizEndTime != null && now.isBefore(quizEndTime!)) {
      setState(() {
        remainingTime = quizEndTime!.difference(now);
      });
    } else {
      timer?.cancel();
      _submitQuiz(auto: true);
    }
  }

  Future<void> _checkAlreadySubmitted() async {
    final uid = await getLoacalStorage("uid");

    if (uid == null || uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User ID not found")),
      );
      return;
    }

    final submissionDoc = await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(widget.quizId)
        .collection('submissions')
        .doc(uid)
        .get();

    if (submissionDoc.exists) {
      _isSubmitted = true;
      final data = submissionDoc.data()!;
      final timeTaken = data['timeTaken'] ?? 0;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: const Text("Already Submitted"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  "Score: ${data['score']} / ${data['selectedAnswers']?.length ?? 'N/A'}"),
              const SizedBox(height: 8),
              Text("Time Taken: $timeTaken seconds"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } else {
      _loadQuestions();
    }
  }

  Future<void> _loadQuestions() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('quizzes')
        .doc(widget.quizId)
        .collection('questions')
        .get();

    if (snapshot.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No questions found in this quiz")),
      );
      return;
    }

    setState(() {
      questions =
          snapshot.docs.map((doc) => {"id": doc.id, ...doc.data()}).toList();
      loading = false;
    });
  }

  Future<void> _submitQuiz({bool auto = false}) async {
    if (_isSubmitted) return;
    _isSubmitted = true;
    timer?.cancel();

    final uid = await getLoacalStorage("uid");

    if (uid == null || uid.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User ID not found")),
      );
      return;
    }

    int score = 0;
    for (var q in questions) {
      final correct = q["correctAnswer"] ?? '';
      final selected = selectedAnswers[q["id"]] ?? '';
      if (selected == correct) score++;
    }

    final timeTaken = (totalDuration.inSeconds - remainingTime.inSeconds)
        .clamp(0, totalDuration.inSeconds);

    try {
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .collection('submissions')
          .doc(uid)
          .set({
        "selectedAnswers": selectedAnswers,
        "score": score,
        "timeTaken": timeTaken,
        "title": title,
        "duration": durationInMinutes,
        "submittedAt": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          title: Text(auto ? "Time's Up!" : "Quiz Submitted"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Score: $score / ${questions.length}"),
              const SizedBox(height: 8),
              Text("Time Taken: $timeTaken seconds"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Submission failed: $e")),
      );
    }
  }

  String _formatTime(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? "$hours:$minutes:$seconds" : "$minutes:$seconds";
  }

  @override
  void dispose() {
    timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isQuizDataLoading || loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentQ = questions[currentIndex];
    final options = List<String>.from(currentQ["options"] ?? []);
    final selected = selectedAnswers[currentQ["id"]] ?? '';
    final attempted = selectedAnswers.length;

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Exit Quiz?"),
            content:
                const Text("Your progress will be lost. Do you want to leave?"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel")),
              TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Leave")),
            ],
          ),
        );
        return shouldExit ?? false;
      },
      child: Scaffold(
        appBar: UiHelpers.customAppBarForScreen(
          context,
          title,
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
                TextButton(
                  onPressed: _isSubmitted
                      ? null
                      : () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text("Confirm Submission"),
                              content: const Text(
                                  "Are you sure you want to submit the quiz?"),
                              actions: [
                                TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel")),
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
                valueColor: const AlwaysStoppedAnimation(Colors.deepPurple),
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
                      Text("Q${currentIndex + 1}. ${currentQ["questionText"]}",
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ...options.map((opt) {
                        final isSelected = selected == opt;
                        return GestureDetector(
                          onTap: () => setState(
                              () => selectedAnswers[currentQ["id"]] = opt),
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
                                        : Colors.grey),
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
                                onPressed: () => setState(() => currentIndex--),
                                child: const Text("Previous")),
                          if (currentIndex < questions.length - 1)
                            ElevatedButton(
                                onPressed: () => setState(() => currentIndex++),
                                child: const Text("Next")),
                        ],
                      ),
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
