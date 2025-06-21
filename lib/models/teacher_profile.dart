class TeacherProfile {
  final String name;
  final String email;
  final String profileImage;
  final String phone;
  final String gender;
  final String dob;
  final String about;
  final String skills;

  // Coaching details
  final String coachingName;
  final String coachingImagesUrl;
  final String coachingAddresss;
  final String coachingCode;

  TeacherProfile({
    required this.name,
    required this.email,
    required this.profileImage,
    required this.phone,
    required this.gender,
    required this.dob,
    required this.about,
    required this.skills,
    required this.coachingAddresss,
    required this.coachingImagesUrl,
    required this.coachingCode,
    required this.coachingName,
  });

  TeacherProfile copyWith({
    String? name,
    String? email,
    String? profileImage,
    String? phone,
    String? gender,
    String? dob,
    String? about,
    String? skills,
    String? coachingAddresss,
    String? coachingImagesUrl,
    String? coachingCode,
    String? coachingName,
  }) {
    return TeacherProfile(
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      about: about ?? this.about,
      skills: skills ?? this.skills,
      coachingAddresss: coachingAddresss ?? this.coachingAddresss,
      coachingImagesUrl: coachingImagesUrl ?? this.coachingImagesUrl,
      coachingCode: coachingCode ?? this.coachingCode,
      coachingName: coachingName ?? this.coachingName,
    );
  }

  factory TeacherProfile.initial() {
    return TeacherProfile(
      name: '',
      email: '',
      profileImage: '',
      phone: '',
      gender: '',
      dob: '',
      about: '',
      skills: '',
      coachingAddresss: '',
      coachingImagesUrl: '',
      coachingCode: '',
      coachingName: '',
    );
  }
}
