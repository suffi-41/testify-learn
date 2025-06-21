import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../utils/helpers.dart';

class AddQuestionsScreen extends StatefulWidget {
  final int totalQuestions;
  final String quizId;

  const AddQuestionsScreen({
    super.key,
    required this.totalQuestions,
    required this.quizId,
  });

  @override
  State<AddQuestionsScreen> createState() => _AddQuestionsScreenState();
}

class _AddQuestionsScreenState extends State<AddQuestionsScreen> {
  int currentIndex = 0;
  final questionController = TextEditingController();
  final List<TextEditingController> optionControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  int selectedOption = 0;
  bool _isLoading = false;

  Future<void> _nextQuestion() async {
    if (questionController.text.isEmpty ||
        optionControllers.any((c) => c.text.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('quizzes')
          .doc(widget.quizId)
          .collection('questions')
          .add({
            'questionText': questionController.text.trim(),
            'options': optionControllers.map((e) => e.text.trim()).toList(),
            'correctOptionIndex': selectedOption,
          });

      if (currentIndex + 1 == widget.totalQuestions) {
        // Mark quiz as published
        // await FirebaseFirestore.instance
        //     .collection('quizzes')
        //     .doc(widget.quizId)
        //     .update({'isPublished': true});

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Test submitted and published!')),
        );
        Navigator.pop(context);
      } else {
        setState(() {
          currentIndex++;
          questionController.clear();
          for (var c in optionControllers) {
            c.clear();
          }
          selectedOption = 0;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving question: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    questionController.dispose();
    for (var c in optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiHelpers.customAppBarForScreen(
        context,
        'Add Questions',
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Question ${currentIndex + 1} of ${widget.totalQuestions}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: (currentIndex + 1) / widget.totalQuestions,
                      minHeight: 6,
                      backgroundColor: Colors.grey[300],
                      color: Colors.blueAccent,
                    ),
                    const SizedBox(height: 16),

                    // Question input
                    SizedBox(
                      height: 80,
                      child: TextField(
                        controller: questionController,
                        maxLines: null,
                        expands: true,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          labelText: 'Question Text',
                          border: OutlineInputBorder(),
                          alignLabelWithHint: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Option fields with radio
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 4,
                      itemBuilder: (_, i) {
                        return RadioListTile<int>(
                          title: TextField(
                            controller: optionControllers[i],
                            decoration: InputDecoration(
                              hintText: 'Option ${String.fromCharCode(65 + i)}',
                            ),
                          ),
                          value: i,
                          groupValue: selectedOption,
                          onChanged: (val) =>
                              setState(() => selectedOption = val!),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // Add/Submit Button or Loader
                    _isLoading
                        ? const CircularProgressIndicator()
                        : SizedBox(
                            width: 300,
                            child: UiHelpers.customButton(
                              context,
                              currentIndex + 1 == widget.totalQuestions
                                  ? 'Submit'
                                  : 'Add Another',
                              _nextQuestion,
                            ),
                          ),

                    const SizedBox(height: 20),
                    const Divider(),

                    // Instructions
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '📌 Instructions:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '• Enter your question in the box above.\n'
                        '• Fill all 4 options and select the correct one.\n'
                        '• Click "Add Another" to move to the next question.\n'
                        '• After the last question, click "Submit" to finish.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
