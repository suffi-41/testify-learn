import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/helpers.dart';
import '../../widgets/modern_detials_row.dart';
import 'package:go_router/go_router.dart';
import '../../utils/cloudinary.dart';

class TeacherProfileScreen extends StatefulWidget {
  const TeacherProfileScreen({super.key});

  @override
  State<TeacherProfileScreen> createState() => _TeacherProfileScreenState();
}

class _TeacherProfileScreenState extends State<TeacherProfileScreen> {
  bool isProfileImage = false;
  bool isCoverImage = false;

  File? profileImageFile;
  File? coverImageFile;

  String teacherName = '';
  String email = '';
  String phone = '';
  String dob = '';
  String gender = '';
  String about = '';
  String skills = '';
  String profileImageUrl = '';
  String coverImageUrl = '';
  String coachingName = '';
  String coachingCode = '';
  String coachingAddress = '';

  final ImagePicker picker = ImagePicker();
  final String suggestInfo = "Add this info";

  Future<void> _pickImage(bool isProfile, String userId) async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    final file = File(image.path);
    setState(() {
      if (isProfile) {
        isProfileImage = true;
      } else {
        isCoverImage = true;
      }
    });

    final url = await uploadImageToCloudinary(
      file,
      folderName: "testify_learn/images",
    );

    await FirebaseFirestore.instance.collection('teachers').doc(userId).update({
      isProfile ? 'teacherImageUrl' : 'coachingImageUrl': url,
    });

    if (!mounted) return;
    setState(() {
      if (isProfile) {
        profileImageFile = file;
        isProfileImage = false;
      } else {
        coverImageFile = file;
        isCoverImage = false;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.white,
        content: Text(
          '${isProfile ? 'Profile' : 'Cover'} image updated',
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  void _showImagePicker(bool isProfile, String userId) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Choose from gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(isProfile, userId);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: Text("User not logged in")));
    }

    return Scaffold(
      appBar: UiHelpers.customAppBarForScreen(
        context,
        "Profile",
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push(
                '/edit-teacher-info/$uid',
                extra: {
                  'name': teacherName,
                  'phone': phone,
                  'dob': dob,
                  'gender': gender,
                  'about': about,
                  'skills': skills,
                },
              );
            },
          ),
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('teachers')
            .doc(uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("No teacher data found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          teacherName = data['fullName'] ?? '';
          email = data['email'] ?? '';
          phone = data['phone'] ?? '';
          dob = data['dob'] ?? '';
          gender = data['gender'] ?? '';
          about = data['about'] ?? '';
          skills = data['skills'] ?? '';
          profileImageUrl = data['teacherImageUrl'] ?? '';
          coverImageUrl = data['coachingImageUrl'] ?? '';
          coachingName = data['coachingName'] ?? '';
          coachingCode = data['coachingCode'] ?? '';
          coachingAddress = data['coachingAddress'] ?? '';

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      height: 200,
                      width: double.infinity,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          isCoverImage
                              ? const Center(child: CircularProgressIndicator())
                              : Image.network(
                                  coverImageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(
                                      'assets/images/default_cover.jpg',
                                      fit: BoxFit.cover,
                                    );
                                  },
                                ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: InkWell(
                              onTap: () => _showImagePicker(false, uid),
                              child: const CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.black54,
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: -50,
                      left: 16,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 6,
                                  color: Colors.black.withOpacity(0.15),
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage:
                                  (profileImageUrl.isNotEmpty &&
                                      !isProfileImage)
                                  ? NetworkImage(profileImageUrl)
                                  : const AssetImage(
                                          'assets/images/default_user.png',
                                        )
                                        as ImageProvider,
                            ),
                          ),
                          if (isProfileImage)
                            const Positioned.fill(
                              child: ColoredBox(
                                color: Colors.black38,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                            ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () => _showImagePicker(true, uid),
                              child: const CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.black54,
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                Text(
                  teacherName.isNotEmpty ? teacherName : suggestInfo,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(email, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: UiHelpers.sectionTitle("Teacher Info"),
                ),
                ModernDetailRow(
                  icon: Icons.phone,
                  label: "Phone",
                  value: phone.isNotEmpty ? phone : suggestInfo,
                ),
                ModernDetailRow(
                  icon: Icons.calendar_month,
                  label: "Date of Birth",
                  value: dob.isNotEmpty ? dob : suggestInfo,
                ),
                ModernDetailRow(
                  icon: Icons.person,
                  label: "Gender",
                  value: gender.isNotEmpty ? gender : suggestInfo,
                ),
                ModernDetailRow(
                  icon: Icons.star,
                  label: "Skills",
                  value: skills.isNotEmpty ? skills : suggestInfo,
                ),
                ModernDetailRow(
                  icon: Icons.info_outline,
                  label: "About",
                  value: about.isNotEmpty ? about : suggestInfo,
                ),

                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: UiHelpers.sectionTitle("Coaching Info"),
                ),
                ModernDetailRow(
                  icon: Icons.school,
                  label: "Coaching Name",
                  value: coachingName,
                ),
                ModernDetailRow(
                  icon: Icons.code,
                  label: "Coaching Code",
                  value: coachingCode,
                ),
                ModernDetailRow(
                  icon: Icons.location_on,
                  label: "Address",
                  value: coachingAddress,
                ),
                ModernDetailRow(
                  icon: Icons.quiz,
                  label: "Total Quizzes",
                  value: '0',
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
