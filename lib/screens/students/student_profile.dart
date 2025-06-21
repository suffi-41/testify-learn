import 'package:flutter/material.dart';
import '../../utils/helpers.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_routes.dart';
import '../../widgets/modern_detials_row.dart';



class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UiHelpers.customAppBarForScreen(
        context,
        "Profile",
        automaticallyImplyLeading: true,
        actions: [
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ✅ Profile pic, name, and email (no card)
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=3',
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Mohd Sufiyan",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                const Text(
                  "sufiyan@example.com",
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 30),

                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Personal Details",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),

                const ModernDetailRow(
                  icon: Icons.phone,
                  label: "Phone",
                  value: "6307874140",
                ),
                const ModernDetailRow(
                  icon: Icons.school,
                  label: "Coaching",
                  value: "XYZ Coaching Institute",
                ),
                const ModernDetailRow(
                  icon: Icons.class_,
                  label: "Class",
                  value: "10th",
                ),
                const ModernDetailRow(
                  icon: Icons.location_city,
                  label: "City",
                  value: "Varanasi",
                ),
                const ModernDetailRow(
                  icon: Icons.calendar_today,
                  label: "Date of Birth",
                  value: "01 Jan 2005",
                ),
                const ModernDetailRow(
                  icon: Icons.person,
                  label: "Gender",
                  value: "Male",
                ),
                const ModernDetailRow(
                  icon: Icons.star,
                  label: "Skills",
                  value: "Flutter, Dart, Firebase",
                ),
                const ModernDetailRow(
                  icon: Icons.info_outline,
                  label: "About",
                  value:
                      "A passionate learner aiming to build great apps with Flutter.",
                ),
                const SizedBox(height: 30),
                TextButton(
                  onPressed: () {
                    
                  },
                  child: Text(
                    "Logout",
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
