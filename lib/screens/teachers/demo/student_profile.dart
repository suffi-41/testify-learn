// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';

// import '../../utils/helpers.dart';
// import '../../constants/app_routes.dart';
// import '../../widgets/modern_detials_row.dart';

// class StudentProfileScreen extends StatelessWidget {
//   const StudentProfileScreen({super.key});

//   Future<void> _logout(BuildContext context) async {
//     try {
//       await FirebaseAuth.instance.signOut();
//       if (context.mounted) {
//         context.go(AppRoutes.login);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Logout failed: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final uid = FirebaseAuth.instance.currentUser?.uid;

//     return Scaffold(
//       appBar: UiHelpers.customAppBarForScreen(
//         context,
//         "Profile",
//         automaticallyImplyLeading: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.edit),
//             onPressed: () {
//               context.push('/edit-student-profile/$uid');
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.settings),
//             onPressed: () {
//               context.push('/student-settings');
//             },
//           ),
//         ],
//       ),
//       body: StreamBuilder<DocumentSnapshot>(
//         stream: FirebaseFirestore.instance
//             .collection('students')
//             .doc(uid)
//             .snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(child: Text("Student data not found"));
//           }

//           final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};

//           return Center(
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 800),
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(10),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const CircleAvatar(
//                       radius: 50,
//                       backgroundImage:
//                           NetworkImage('https://i.pravatar.cc/150?img=3'),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       data['fullName'] ?? 'Name not available',
//                       style: const TextStyle(
//                           fontSize: 24, fontWeight: FontWeight.w600),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       FirebaseAuth.instance.currentUser?.email ?? '',
//                       style: const TextStyle(color: Colors.grey),
//                     ),
//                     const SizedBox(height: 30),
//                     const Align(
//                       alignment: Alignment.centerLeft,
//                       child: Text(
//                         "Personal Details",
//                         style: TextStyle(
//                             fontSize: 20, fontWeight: FontWeight.bold),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     ModernDetailRow(
//                       icon: Icons.phone,
//                       label: "Phone",
//                       value: data['phone'] ?? 'N/A',
//                     ),
//                     ModernDetailRow(
//                       icon: Icons.school,
//                       label: "Coaching",
//                       value: data['coaching'] ?? 'N/A',
//                     ),
//                     ModernDetailRow(
//                       icon: Icons.class_,
//                       label: "Class",
//                       value: data['class'] ?? 'N/A',
//                     ),
//                     ModernDetailRow(
//                       icon: Icons.location_city,
//                       label: "City",
//                       value: data['city'] ?? 'N/A',
//                     ),
//                     ModernDetailRow(
//                       icon: Icons.calendar_today,
//                       label: "Date of Birth",
//                       value: data['dob'] ?? 'N/A',
//                     ),
//                     ModernDetailRow(
//                       icon: Icons.person,
//                       label: "Gender",
//                       value: data['gender'] ?? 'N/A',
//                     ),
//                     ModernDetailRow(
//                       icon: Icons.star,
//                       label: "Skills",
//                       value: data['skills'] ?? 'N/A',
//                     ),
//                     ModernDetailRow(
//                       icon: Icons.info_outline,
//                       label: "About",
//                       value: data['about'] ?? 'N/A',
//                     ),
//                     const SizedBox(height: 30),
//                     TextButton.icon(
//                       icon: const Icon(Icons.logout, color: Colors.redAccent),
//                       label: const Text(
//                         "Logout",
//                         style: TextStyle(color: Colors.redAccent),
//                       ),
//                       onPressed: () => _logout(context),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
