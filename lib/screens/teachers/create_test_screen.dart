import 'package:flutter/material.dart';
import '../../widgets/add_question_screen.dart';
import '../../utils/helpers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/firebase_service.dart';
import '../../utils/loacl_storage.dart';

class CreateTestScreen extends StatefulWidget {
  const CreateTestScreen({super.key});

  @override
  State<CreateTestScreen> createState() => _CreateTestScreenState();
}

class _CreateTestScreenState extends State<CreateTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _dateController = TextEditingController();

  String? selectedFee;
  String? selectedDuration;
  String? selectedMCQ;
  bool _isLoading = false; // <-- added loading flag

  final List<String> feeOptions = ['₹15', '₹25', '₹50', '₹75', '₹100'];
  final List<String> durationOptions = [
    '20 min',
    '30 min',
    '40 min',
    '50 min',
    '60 min',
  ];
  final List<String> mcqOptions = [
    '10 (mcq)',
    '20 (mcq)',
    '30 (mcq)',
    '40 (mcq)',
    '50 (mcq)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiHelpers.customAppBarForScreen(context, "Create Test"),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        _titleController,
                        'Test Title',
                        prefixIcon: const Icon(Icons.title),
                      ),
                      _buildDatePicker(),
                      _buildDropdown(
                        'Fee(₹)',
                        selectedFee,
                        feeOptions,
                        (val) => setState(() => selectedFee = val),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                      _buildDropdown(
                        'Duration (min)',
                        selectedDuration,
                        durationOptions,
                        (val) => setState(() => selectedDuration = val),
                        prefixIcon: const Icon(Icons.timer),
                      ),
                      _buildDropdown(
                        'MCQ',
                        selectedMCQ,
                        mcqOptions,
                        (val) => setState(() => selectedMCQ = val),
                        prefixIcon: const Icon(Icons.help_outline),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: _isLoading
                            ? const CircularProgressIndicator() // <-- show loader
                            : UiHelpers.customButton(
                                context,
                                "Add Questions",
                                () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(
                                      () => _isLoading = true,
                                    ); // start loading

                                    int totalQuestions = int.tryParse(
                                          selectedMCQ?.split(' ').first ?? '0',
                                        ) ??
                                        0;

                                    try {
                                      final uid = await getLoacalStorage("uid");

                                      String? code =
                                          await coachingCode(uid.toString());

                                      final quizRef = await FirebaseFirestore
                                          .instance
                                          .collection('quizzes')
                                          .add({
                                        'title': _titleController.text.trim(),
                                        'fee': selectedFee,
                                        'duration': selectedDuration,
                                        'isPublished': false,
                                        'totalQuestions': totalQuestions,
                                        'testDateTime':
                                            _dateController.text.trim(),
                                        'createdAt':
                                            FieldValue.serverTimestamp(),
                                        'createdBy':
                                            uid, // Replace with actual user ID
                                        'coachingCode': code,
                                        'isLive': false,
                                        'isCompleted': false,
                                      });

                                      setState(
                                        () => _isLoading = false,
                                      ); // stop loading

                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddQuestionsScreen(
                                            totalQuestions: totalQuestions,
                                            quizId: quizRef.id,
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      setState(
                                        () => _isLoading = false,
                                      ); // stop loading on error

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            "Failed to create test: $e",
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                      ),
                      const SizedBox(height: 30),
                      const Divider(),
                      const Text(
                        "Note:",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Make sure all details are correct before proceeding. You will be redirected to add all questions immediately.",
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.warning, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Warning: Once you start adding questions, you must complete the process. You cannot return to edit the test settings later.",
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    Widget? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: prefixIcon,
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _dateController,
        readOnly: true,
        decoration: const InputDecoration(
          labelText: 'Test Date & Time',
          suffixIcon: Icon(Icons.calendar_today),
          prefixIcon: Icon(Icons.event),
          border: OutlineInputBorder(),
        ),
        onTap: () async {
          FocusScope.of(context).unfocus();

          DateTime? date = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2100),
          );

          if (date != null) {
            TimeOfDay? time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );

            if (time != null) {
              final combined = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );

              final formatted = "${combined.day.toString().padLeft(2, '0')}-"
                  "${combined.month.toString().padLeft(2, '0')}-"
                  "${combined.year} "
                  "${time.format(context)}";

              _dateController.text = formatted;
            }
          }
        },
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'Please select date and time';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(
    String hint,
    String? value,
    List<String> options,
    ValueChanged<String?> onChanged, {
    Widget? prefixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: value,
        items: options
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: hint,
          border: const OutlineInputBorder(),
          prefixIcon: prefixIcon,
        ),
        validator: (val) => val == null ? 'Please select $hint' : null,
      ),
    );
  }
}
