import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveJwtToken(String token) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('jwt_token', token);
}

Future<String?> getJwtToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwt_token');
}

Future<void> removeJwtToken() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove('jwt_token');
}
