import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Generates a random alphanumeric string of [length]
String _randomSuffix(int length) {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  final rand = Random();
  return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
}

/// Cleans and formats the coaching name prefix (e.g., "Elite Academy" → "ELITE")
String _generateNamePrefix(String coachingName) {
  final cleaned = coachingName.trim().toUpperCase().replaceAll(
        RegExp(r'[^A-Z0-9]'),
        '',
      );
  return cleaned.length >= 5
      ? cleaned.substring(0, 5)
      : cleaned.padRight(5, 'X');
}

/// Main function to generate and store a unique coaching code
Future<String> generateUniqueCoachingCode({
  required String coachingName,
}) async {
  final firestore = FirebaseFirestore.instance;
  final coachingCollection = firestore.collection('teachers');

  String? code;
  bool isUnique = false;
  final prefix = _generateNamePrefix(coachingName); // e.g., ELITE

  while (!isUnique) {
    // Generate code like "ELITE-3X5ZP2"
    final suffix = _randomSuffix(6);
    code = '$prefix-$suffix';

    // Check uniqueness in Firestore
    final query =
        await coachingCollection.where('code', isEqualTo: code).limit(1).get();

    if (query.docs.isEmpty) {
      isUnique = true;
    }
  }

  return code!;
}
