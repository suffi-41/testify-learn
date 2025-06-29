import 'package:flutter/material.dart';
import '../../utils/helpers.dart';
import '../../widgets/state_box.dart';

class Student {
  final int number;
  final String name;
  final String email;
  bool isPresent;

  Student({
    required this.number,
    required this.name,
    required this.email,
    this.isPresent = false,
  });
}

class StudentsAttandanceScreen extends StatefulWidget {
  final String quizId;
  const StudentsAttandanceScreen({super.key, required this.quizId});

  @override
  State<StudentsAttandanceScreen> createState() =>
      _StudentsAttandanceScreenState();
}

class _StudentsAttandanceScreenState extends State<StudentsAttandanceScreen> {
  List<Student> students = [
    Student(
        number: 1,
        name: "MD AFFAN",
        email: "mdafan5454@gmail.com",
        isPresent: true),
    Student(number: 2, name: "MOHD SUFIYAN", email: "mdsufiyan454@gmail.com"),
    Student(
        number: 3,
        name: "MD REHAN",
        email: "mdrehan5409@gmail.com",
        isPresent: true),
    Student(
        number: 5,
        name: "MD YASIR",
        email: "mdyasir0@gmail.com",
        isPresent: true),
    Student(number: 6, name: "RAHUL KUMAR", email: "rahul04@gmail.com"),
    Student(number: 7, name: "MD FARHAN", email: "mdafarh2an54@gmail.com"),
    Student(number: 8, name: "MD FARHAN", email: "mdaf7arhan54@gmail.com"),
    Student(number: 9, name: "MD FARHAN", email: "mdafarh3an54@gmail.com"),
  ];

  int get presentCount => students.where((s) => s.isPresent).length;
  int get absentCount => students.length - presentCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiHelpers.customAppBarForScreen(context, "Attendance",
          automaticallyImplyLeading: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.done),
              onPressed: () {},
            ),
          ]),
      body: Column(
        children: [
          _headerSection(),
          _tableHeader(),
          Expanded(child: _studentList()),
        ],
      ),
    );
  }

  Widget _headerSection() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "English test for class X",
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatBox(
                count: presentCount.toString(),
                label: "Present",
                color: Colors.green,
                icon: Icons.check_circle,
              ),
              StatBox(
                count: absentCount.toString(),
                label: "Absent",
                color: Colors.red,
                icon: Icons.cancel,
              ),
              StatBox(
                count: "15:00",
                label: " min left",
                color: Colors.red.shade200,
                icon: Icons.lock_clock,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: 25,
        vertical: 10,
      ),
      child: Row(
        children: const [
          SizedBox(width: 8),
          Expanded(
              flex: 1,
              child:
                  Text("S.No", style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
              flex: 3,
              child:
                  Text("Name", style: TextStyle(fontWeight: FontWeight.w600))),
          Expanded(
              flex: 2,
              child: Text("Status",
                  style: TextStyle(fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }

  Widget _studentList() {
    return ListView.separated(
      itemCount: students.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final s = students[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple,
              radius: 20,
              child: Text(
                s.number.toString().padLeft(2, '0'),
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(s.name,
                style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle:
                Text(s.email, style: TextStyle(color: Colors.grey.shade700)),
            trailing: Switch(
              value: s.isPresent,
              onChanged: (val) {
                setState(() => s.isPresent = val);
              },
              activeColor: Colors.deepPurple,
            ),
          ),
        );
      },
    );
  }
}
