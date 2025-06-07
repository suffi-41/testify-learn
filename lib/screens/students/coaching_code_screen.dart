import 'package:flutter/material.dart';
import '../../utils/helpers.dart';
import '../../utils/responsive.dart';

class CoachingCodeScreen extends StatelessWidget {
  const CoachingCodeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController codeController = TextEditingController();

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Column(
                    children: [
                      Text(
                        'Welcome Back!',
                        style: Theme.of(context).textTheme.displayLarge,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter the coaching code given by sir',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                ResponsiveLayout(
                  mobile: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _image(),
                        const SizedBox(height: 30),
                        _joinSection(context, codeController),
                      ],
                    ),
                  ),
                  tablet: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        SizedBox(height: 100),
                        _image(),
                        const SizedBox(width: 40),
                        SizedBox(
                          width: 350,
                          child: _joinSection(context, codeController),
                        ),
                      ],
                    ),
                  ),

                  desktop: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        const SizedBox(height: 100),
                        _image(),
                        const SizedBox(width: 60),
                        _joinSection(context, codeController),
                      ],
                    ),
                  ),
                  largeDesttop: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,

                      children: [
                        const SizedBox(height: 100),
                        _image(),
                        const SizedBox(width: 60),
                        _joinSection(context, codeController),
                      ],
                    ),
                  ),
                ),
                // ⬇️ Bottom instruction added here
                const SizedBox(height: 30),
                const Text(
                  'Please make sure you enter the correct code shared by your coaching admin.',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _image() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        'assets/images/study_illustration.png',
        height: 200,
        width: 200,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _joinSection(BuildContext context, TextEditingController controller) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Coaching Joining Code',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              UiHelpers.customTextField(
                context,
                controller: controller,
                hintText: 'Coaching code',
                validator: (value) =>
                    value == null || value.isEmpty ? 'Code is required' : null,
                prefixIcon: const Icon(Icons.join_inner_sharp),
              ),
              const SizedBox(height: 20),
              UiHelpers.customButton(context, "Submit", () {
                // Add submission logic here
              }),
            ],
          ),
        ),
      ),
    );
  }
}
