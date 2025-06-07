import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// routes name
import '../../../constants/app_routes.dart';

import '../../../utils/helpers.dart';
import '../../../utils/responsive.dart';
import '../../../widgets/picker_images.dart';
import '../../../utils/cloudinary.dart';

// redux
import 'package:flutter_redux/flutter_redux.dart';
import '../../../redux/actions/auth_actions.dart';
import '../../../models/root_state.dart';

class TeacherSignup extends StatefulWidget {
  const TeacherSignup({super.key});

  @override
  State<TeacherSignup> createState() => _TeacherSignupState();
}

class _TeacherSignupState extends State<TeacherSignup> {
  final _formKey = GlobalKey<FormState>();

  // Teacher Details
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  // Coaching Details
  final TextEditingController coachingNameController = TextEditingController();
  final TextEditingController coachingAddressController =
      TextEditingController();
  final TextEditingController subjectsController = TextEditingController();

  // KYC Details
  final TextEditingController aadharController = TextEditingController();
  final TextEditingController panController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  String? teacherImageUrl;
  String? coachingImageUrl;

  bool isUploadingTeacherImage = false;
  bool isUploadingCoachingImage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: UiHelpers.customAuthAppBar(context, "Sign In", () {
        context.replace(AppRoutes.login);
      }),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: _form(),
      ),
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Create Teacher Account",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Fill in your personal and coaching details",
            style: TextStyle(color: Colors.grey),
          ),
          ResponsiveLayout(
            mobile: Column(
              children: [
                const SizedBox(height: 24),
                UiHelpers.sectionTitle("Teacher Details"),
                const SizedBox(height: 12),
                _teacherDetails(),
                const SizedBox(height: 32),
                UiHelpers.sectionTitle("Coaching Details"),
                const SizedBox(height: 12),
                _coachingDetails(),
              ],
            ),
            tablet: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UiHelpers.sectionTitle("Teacher Details"),
                      const SizedBox(height: 12),
                      _teacherDetails(),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      UiHelpers.sectionTitle("Coaching Details"),
                      const SizedBox(height: 12),
                      _coachingDetails(),
                    ],
                  ),
                ),
              ],
            ),
            desktop: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UiHelpers.sectionTitle("Teacher Details"),
                          const SizedBox(height: 12),
                          _teacherDetails(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UiHelpers.sectionTitle("Coaching Details"),
                          const SizedBox(height: 12),
                          _coachingDetails(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            largeDesttop: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UiHelpers.sectionTitle("Teacher Details"),
                          const SizedBox(height: 12),
                          _teacherDetails(),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          UiHelpers.sectionTitle("Coaching Details"),
                          const SizedBox(height: 12),
                          _coachingDetails(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Inside the Submit button
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : UiHelpers.customButton(context, "Submit", () async {
                  if (_formKey.currentState!.validate()) {
                    if (teacherImageUrl == null || coachingImageUrl == null) {
                      UiHelpers.showSnackbar(
                        context,
                        "Please upload both images.",
                      );
                      return;
                    }

                    setState(() {
                      _isLoading = true;
                    });

                    final String email = emailController.text.trim();
                    final String password = passwordController.text.trim();
                    final String name = fullNameController.text.trim();
                    final String phone = phoneController.text.trim();
                    final String coachingName = coachingNameController.text
                        .trim();
                    final String coachingAddress = coachingAddressController
                        .text
                        .trim();

                    final store = StoreProvider.of<RootState>(context);

                    store.dispatch(
                      StartTeacherSignup(
                        email: email,
                        password: password,
                        fullName: name,
                        phone: phone,
                        coachingName: coachingName,
                        coachingAddress: coachingAddress,
                        teacherImageUrl: teacherImageUrl!,
                        coachingImageUrl: coachingImageUrl!,
                        onSuccess: () {
                          setState(() {
                            _isLoading = false;
                          });
                          UiHelpers.showSnackbar(
                            context,
                            "Signup successful",
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.secondary,
                          );
                          context.go(AppRoutes.emailVerification);
                        },
                        onFailure: (error) {
                          setState(() {
                            _isLoading = false;
                          });
                          UiHelpers.showSnackbar(
                            context,
                            "Signup failed: $error",
                          );
                        },
                      ),
                    );
                  }
                }),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _teacherDetails() {
    return Column(
      children: [
        UiHelpers.customTextField(
          context,
          hintText: "Full Name",
          controller: fullNameController,
          prefixIcon: Icon(Icons.person),
          validator: (val) => val == null || val.trim().isEmpty
              ? 'Full Name is required'
              : null,
        ),
        const SizedBox(height: 16),
        UiHelpers.customTextField(
          context,
          hintText: "Email Address",
          controller: emailController,
          prefixIcon: Icon(Icons.email),
          keyboardType: TextInputType.emailAddress,
          validator: (val) =>
              val == null || !val.contains('@') ? 'Enter a valid email' : null,
        ),
        const SizedBox(height: 16),
        UiHelpers.customTextField(
          context,
          hintText: "Phone Number",
          controller: phoneController,
          prefixIcon: Icon(Icons.phone),
          keyboardType: TextInputType.phone,
          validator: (val) => val == null || val.length != 10
              ? 'Enter a valid 10-digit phone number'
              : null,
        ),
        const SizedBox(height: 16),
        UiHelpers.customTextField(
          context,
          hintText: "Password",
          controller: passwordController,
          prefixIcon: const Icon(Icons.lock),
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (val) => val != null && val.length < 6
              ? 'Password must be at least 6 characters'
              : null,
        ),
      ],
    );
  }

  Widget _coachingDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        UiHelpers.customTextField(
          context,
          hintText: "Coaching Name",
          controller: coachingNameController,
          prefixIcon: Icon(Icons.business),
          validator: (val) => val == null || val.trim().isEmpty
              ? 'Coaching name is required'
              : null,
        ),
        const SizedBox(height: 16),
        UiHelpers.customTextField(
          context,
          hintText: "Coaching Address",
          controller: coachingAddressController,
          prefixIcon: Icon(Icons.location_on),
          validator: (val) =>
              val == null || val.trim().isEmpty ? 'Address is required' : null,
        ),
        const SizedBox(height: 24),
        UiHelpers.sectionTitle("Upload Image"),
        const SizedBox(height: 10),
        ImagePickerWidget(
          onImageSelected: (file) async {
            setState(() {
              isUploadingTeacherImage = true;
            });
            final url = await uploadImageToCloudinary(
              file,
              folderName: "testify_learn/images",
            );
            log(url.toString());
            if (url != null) {
              setState(() {
                teacherImageUrl = url;
                isUploadingTeacherImage = false;
              });
              log("Coaching teacher uploaded: $url");
            }
          },
          title: "Upload teacher image",
          isLoading: isUploadingTeacherImage,
        ),
        const SizedBox(height: 24),

        ImagePickerWidget(
          onImageSelected: (file) async {
            setState(() {
              isUploadingCoachingImage = true;
            });
            final url = await uploadImageToCloudinary(
              file,
              folderName: "testify_learn/images",
            );
            if (url != null) {
              setState(() {
                coachingImageUrl = url;
                isUploadingCoachingImage = false;
              });
            }
          },
          title: "Upload coaching image",
          isLoading: isUploadingCoachingImage,
        ),
      ],
    );
  }
}
