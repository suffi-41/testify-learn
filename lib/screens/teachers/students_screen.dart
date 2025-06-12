import 'package:flutter/material.dart';
// import '../';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: SafeArea(
        child: Column(
          children: [
            // Top AppBar
            Container(
              color: const Color(0xFF6C40BD),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    'Students',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.purple.shade200),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search students',
                  prefixIcon: const Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            // Student List
            const Expanded(child: StudentList()),
          ],
        ),
      ),
    );
  }
}

class StudentList extends StatelessWidget {
  const StudentList({super.key});

  final List<Map<String, String>> students = const [
    {
      'name': 'Mohd Affan',
      'email': 'mdafans545@gmail.com',
      'join': '14-03-2025',
      'won': '4',
    },
    {
      'name': 'Mohd Sufiyan',
      'email': 'mdsufiyan54@gmail.com',
      'join': '15-04-2025',
      'won': '7',
    },
    {
      'name': 'Mohd Sameer',
      'email': 'mdsameer54@gmail.com',
      'join': '14-02-2025',
      'won': '2',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final initials = student['name']!
            .split(' ')
            .map((e) => e[0])
            .take(2)
            .join()
            .toUpperCase();

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.purple.shade100.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.purple,
              child: Text(
                initials,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              student['name']!,
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(student['email']!, style: const TextStyle(fontSize: 13)),
                Text(
                  'join: ${student['join']}   Won: ${student['won']}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF6C40BD),
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.white70,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: ''),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: '',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
      ],
    );
  }
}
