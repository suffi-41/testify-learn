import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_routes.dart';
import '../../utils/helpers.dart';
import '../../utils/responsive.dart';
import '../../utils/loacl_storage.dart';

class CoachingCodeScreen extends StatefulWidget {
  const CoachingCodeScreen({super.key});
  @override
  State<CoachingCodeScreen> createState() => _CoachingCodeScreenState();
}

class _CoachingCodeScreenState extends State<CoachingCodeScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool isFocused = false;
  bool isLoading = false;
  List<String> coachingCodes = [];
  List<String> filteredCodes = [];

  @override
  void initState() {
    super.initState();
    _loadJoinedCodes();
    _controller.addListener(_inputListener);

    _focusNode.addListener(() {
      setState(() {
        isFocused = _focusNode.hasFocus;
        if (isFocused && _controller.text.isEmpty) {
          filteredCodes = List.from(coachingCodes);
        }
      });
    });
  }

  void _inputListener() {
    final input = _controller.text.toLowerCase();
    setState(() {
      filteredCodes = coachingCodes
          .where((code) => code.toLowerCase().contains(input))
          .toList();
    });
  }

  Future<void> _loadJoinedCodes() async {
    final uid = await getLoacalStorage("uid");
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection("students")
        .doc(uid)
        .collection("coachingCodes")
        .get();

    coachingCodes = snapshot.docs
        .map((doc) => doc.data()['code']?.toString())
        .whereType<String>()
        .toList();

    filteredCodes = List.from(coachingCodes);
    setState(() {});
  }

  Future<void> _submitCode() async {
    final inputCode = _controller.text.trim().toUpperCase();

    if (inputCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a coaching code')),
      );
      _focusNode.requestFocus();
      return;
    }

    final uid = await getLoacalStorage("uid");
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Check if the coaching code exists in the teachers collection
      final teacherSnapshot = await FirebaseFirestore.instance
          .collection('teachers')
          .where('coachingCode', isEqualTo: inputCode)
          .get();

      if (teacherSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid coaching code')),
        );
        return;
      }

      final coachingDocRef = FirebaseFirestore.instance
          .collection("students")
          .doc(uid)
          .collection("coachingCodes")
          .doc(inputCode);

      final coachingDoc = await coachingDocRef.get();

      if (coachingDoc.exists) {
        // Already joined
        await _storeLocallyAndRedirect(inputCode);
        return;
      }

      // Add new coaching code
      await coachingDocRef.set({
        'code': inputCode,
        'joinedAt': Timestamp.now(),
      });

      await _storeLocallyAndRedirect(inputCode);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _storeLocallyAndRedirect(String code) async {
    await saveLoacalStorage("coachingCode", code);

    if (mounted) {
      context.go(AppRoutes.studentDashboard);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_inputListener);
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
    return Column(
      children: [
        _image(),
        const SizedBox(height: 30),
        _joinSection(),
      ],
    );
  }

  Widget _layoutRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _image(),
        const SizedBox(width: 60),
        SizedBox(width: 400, child: _joinSection()),
      ],
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

  Widget _joinSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Card(
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Type coaching code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.school),
                  ),
                ),
                const SizedBox(height: 60),
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : UiHelpers.customButton(context, "Submit", _submitCode),
              ],
            ),
          ),
        ),

        /// Dropdown List
        if (isFocused && filteredCodes.isNotEmpty)
          Positioned(
            top: 110,
            left: 0,
            right: 0,
            child: Material(
              elevation: 4,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                constraints: const BoxConstraints(maxHeight: 180),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  shrinkWrap: true,
                  itemCount: filteredCodes.length,
                  itemBuilder: (context, index) {
                    final code = filteredCodes[index];
                    return ListTile(
                      title: Text(code),
                      onTap: () {
                        setState(() {
                          _controller
                            ..removeListener(_inputListener)
                            ..text = code
                            ..selection =
                                TextSelection.collapsed(offset: code.length)
                            ..addListener(_inputListener);
                          filteredCodes.clear();
                          _focusNode.unfocus();
                        });
                      },
                    );
                  },
                ),
              ),
            ),
          ),
      ],
    );
  }
}
