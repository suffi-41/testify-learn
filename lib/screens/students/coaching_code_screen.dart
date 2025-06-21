import 'package:flutter/material.dart';
import '../../utils/helpers.dart';
import '../../utils/responsive.dart';

class CoachingCodeScreen extends StatefulWidget {
  const CoachingCodeScreen({super.key});

  @override
  State<CoachingCodeScreen> createState() => _CoachingCodeScreenState();
}

class _CoachingCodeScreenState extends State<CoachingCodeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String? selectedCode;
  bool isFocused = false;

  final List<String> coachingCodes = [
    'ABC123',
    'XYZ456',
    'DKAHSS',
    'MATH101',
    'SCIENCE202',
    'HIST999',
  ];

  List<String> filteredCodes = [];

  void _submitCode() {
    if (selectedCode == null || selectedCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or enter a coaching code')),
      );
      return;
    }

    print('Submitted Coaching Code: $selectedCode');
    // Add Firebase/Navigation logic here
  }

  @override
  void initState() {
    super.initState();

    _controller.addListener(() {
      final input = _controller.text.toLowerCase();
      setState(() {
        selectedCode = _controller.text;
        filteredCodes = coachingCodes
            .where((code) => code.toLowerCase().contains(input))
            .toList();
      });
    });

    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
        if (isFocused && _controller.text.isEmpty) {
          filteredCodes = List.from(coachingCodes);
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              Text('Welcome Back!',
                  style: Theme.of(context).textTheme.displayLarge),
              const SizedBox(height: 8),
              const Text(
                'Enter the coaching code given by sir',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ResponsiveLayout(
                mobile: _layoutColumn(),
                tablet: _layoutRow(),
                desktop: _layoutRow(),
                largeDesttop: _layoutRow(),
              ),
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
    );
  }

  Widget _layoutColumn() {
    return Center(
      child: Column(
        children: [
          _image(),
          const SizedBox(height: 30),
          _joinSection(context),
        ],
      ),
    );
  }

  Widget _layoutRow() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _image(),
          const SizedBox(width: 60),
          SizedBox(width: 400, child: _joinSection(context)),
        ],
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

  Widget _joinSection(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter Coaching Code',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _controller,
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Type coaching code',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.school),
              ),
            ),
            const SizedBox(height: 10),
            if (isFocused && filteredCodes.isNotEmpty)
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: filteredCodes.length,
                  itemBuilder: (context, index) {
                    final code = filteredCodes[index];
                    return ListTile(
                      title: Text(code),
                      onTap: () {
                        setState(() {
                          _controller.text = code;
                          selectedCode = code;
                          filteredCodes.clear();
                          _focusNode.unfocus();
                        });
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),
            UiHelpers.customButton(context, "Submit", _submitCode),
          ],
        ),
      ),
    );
  }
}
