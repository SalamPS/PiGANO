import 'package:shared_preferences/shared_preferences.dart';

// Menyimpan data
Future<void> saveData(String key, String value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(key, value);
}

// Mengambil data
Future<String> getData(String key) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(key) ?? "";
}