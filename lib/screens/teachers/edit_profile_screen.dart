import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../utils/helpers.dart';

class EditTeacherInfoScreen extends StatefulWidget {
  final Map<String, dynamic> initialData;
  final String uid;

  const EditTeacherInfoScreen({
    super.key,
    required this.initialData,
    required this.uid,
  });

  @override
  State<EditTeacherInfoScreen> createState() => _EditTeacherInfoScreenState();
}

class _EditTeacherInfoScreenState extends State<EditTeacherInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController dobController;
  late TextEditingController genderController;
  late TextEditingController aboutController;
  late TextEditingController skillsController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(
      text: widget.initialData['name'] ?? '',
    );
    phoneController = TextEditingController(
      text: widget.initialData['phone'] ?? '',
    );
    dobController = TextEditingController(
      text: widget.initialData['dob'] ?? '',
    );
    genderController = TextEditingController(
      text: widget.initialData['gender'] ?? '',
    );
    aboutController = TextEditingController(
      text: widget.initialData['about'] ?? '',
    );
    skillsController = TextEditingController(
      text: widget.initialData['skills'] ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    dobController.dispose();
    genderController.dispose();
    aboutController.dispose();
    skillsController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isSaving = true);

      final updatedData = {
        'fullName': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'dob': dobController.text.trim(),
        'gender': genderController.text.trim(),
        'about': aboutController.text.trim(),
        'skills': skillsController.text.trim(),
      };

      try {
        await FirebaseFirestore.instance
            .collection('teachers')
            .doc(widget.uid)
            .update(updatedData);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile updated successfully")),
        );

        Navigator.pop(context, updatedData);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Failed to update: $e")));
      } finally {
        setState(() => isSaving = false);
      }
    }
  }

  bool _isValidDate(String input) {
    try {
      final parsed = DateFormat('yyyy-MM-dd').parseStrict(input);
      return parsed.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  bool _isValidGender(String input) {
    final value = input.trim().toLowerCase();
    return ['male', 'female', 'other'].contains(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiHelpers.customAppBarForScreen(
        context,
        "Edit Profile Info",
        actions: [
          IconButton(
            icon: isSaving
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: const CircularProgressIndicator(color: Colors.white),
                  )
                : const Icon(Icons.check),
            onPressed: isSaving ? null : _saveChanges,
          ),
        ],
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              UiHelpers.customTextField(
                context,
                controller: nameController,
                hintText: "Name",
                prefixIcon: const Icon(Icons.person),
                validator: (value) =>
                    value!.trim().isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 16),
              UiHelpers.customTextField(
                context,
                controller: phoneController,
                hintText: "Phone",
                prefixIcon: const Icon(Icons.phone),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Phone is required";
                  }
                  if (!RegExp(r'^\d{10}$').hasMatch(value.trim())) {
                    return "Enter a valid 10-digit phone number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              UiHelpers.customTextField(
                context,
                controller: dobController,
                hintText: "Date of Birth (yyyy-MM-dd)",
                prefixIcon: const Icon(Icons.calendar_today),
                validator: (value) {
                  if (!_isValidDate(value.trim())) {
                    return "Enter valid past date in yyyy-MM-dd format";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              UiHelpers.customTextField(
                context,
                controller: genderController,
                hintText: "Gender (Male/Female/Other)",
                prefixIcon: const Icon(Icons.person_outline),
                validator: (value) {
                  if (!_isValidGender(value)) {
                    return "Enter Male, Female, or Other";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              UiHelpers.customTextField(
                context,
                controller: aboutController,
                hintText: "About",
                prefixIcon: const Icon(Icons.info_outline),
                validator: (value) => null,
              ),
              const SizedBox(height: 16),
              UiHelpers.customTextField(
                context,
                controller: skillsController,
                hintText: "Skills",
                prefixIcon: const Icon(Icons.star),
                validator: (value) => null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
