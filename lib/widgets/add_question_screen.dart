import 'package:flutter/material.dart';
import '../utils/helpers.dart';

class Question {
  final String questionText;
  final List<String> options;
  final int correctIndex;

  Question({
    required this.questionText,
    required this.options,
    required this.correctIndex,
  });
}

class AddQuestionsScreen extends StatefulWidget {
  final int totalQuestions;
  const AddQuestionsScreen({super.key, required this.totalQuestions});

  @override
  State<AddQuestionsScreen> createState() => _AddQuestionsScreenState();
}

class _AddQuestionsScreenState extends State<AddQuestionsScreen> {
  int currentIndex = 0;
  final List<Question> questions = [];

  final questionController = TextEditingController();
  final List<TextEditingController> optionControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  int selectedOption = 0;

  void _nextQuestion() {
    if (questionController.text.isEmpty ||
        optionControllers.any((c) => c.text.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    questions.add(
      Question(
        questionText: questionController.text,
        options: optionControllers.map((e) => e.text).toList(),
        correctIndex: selectedOption,
      ),
    );

    if (currentIndex + 1 == widget.totalQuestions) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Test submitted!')));
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

                    // Multiline question input
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

                    // Option input fields with Radio
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

                    SizedBox(
                      width: 300,
                      child: UiHelpers.customButton(
                        context,
                        currentIndex + 1 == widget.totalQuestions
                            ? 'Submit'
                            : 'Add another',
                      
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
                        '• Click "Add another" to move to the next question.\n'
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
