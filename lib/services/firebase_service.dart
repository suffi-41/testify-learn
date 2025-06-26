import 'package:cloud_firestore/cloud_firestore.dart';

Future<String?> getUserRole(String uid) async {
  final firestore = FirebaseFirestore.instance;
  try {
    // Check in students collection
    final studentDoc = await firestore.collection('students').doc(uid).get();
    if (studentDoc.exists) {
      return 'student';
    }

    // Check in teachers collection
    final teacherDoc = await firestore.collection('teachers').doc(uid).get();
    if (teacherDoc.exists) {
      return 'teacher';
    }

    // If not found in both
    return null;
  } catch (e) {
    print('Error fetching user role: $e');
    return null;
  }
}

Future<bool> isGoogleWithSignIn(String uid) async {
  try {
    final doc =
        await FirebaseFirestore.instance.collection("students").doc(uid).get();

    if (doc.exists) {
      final data = doc.data();
      return data?['isGoogle'] == true;
    } else {
      return false;
    }
  } catch (e) {
    print("Error checking Google Sign-In status: $e");
    return false;
  }
}

Future<String?> coachingCode(String uid) async {
  try {
    final doc =
        await FirebaseFirestore.instance.collection("teachers").doc(uid).get();

    if (doc.exists && doc.data() != null) {
      return doc.data()!['coachingCode'] as String?;
    } else {
      return null;
    }
  } catch (e) {
    print("Error fetching coachingCode for uid '$uid': $e");
    return null;
  }
}

Future<Map<String, dynamic>?> userDetails(
  String uid,
  String collections,
) async {
  try {
    final doc =
        await FirebaseFirestore.instance.collection(collections).doc(uid).get();

    if (doc.exists && doc.data() != null) {
      return doc.data();
    } else {
      return null;
    }
  } catch (e) {
    print("Error fetching userDetails for uid '$uid': $e");
    return null;
  }
}
