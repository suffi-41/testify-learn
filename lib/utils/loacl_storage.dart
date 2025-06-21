import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveLoacalStorage(String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

Future<String?> getLoacalStorage(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key);
}

Future<void> removeLoacalStorage(String key) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(key);
}

Future<void> clearLoacalStoraye() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
}
