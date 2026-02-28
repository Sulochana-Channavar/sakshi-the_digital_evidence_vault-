import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  // ================= LOGIN =================
  static Future<bool> login(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();

    String? savedEmail = prefs.getString("user_email");
    String? savedPassword = prefs.getString("user_password");

    if (email == savedEmail && password == savedPassword) {
      await prefs.setBool("logged_in", true);
      return true;
    }

    return false;
  }

  // ================= REGISTER =================
  static Future<bool> register(
      String email, String password) async {

    final prefs = await SharedPreferences.getInstance();

    await prefs.setString("user_email", email);
    await prefs.setString("user_password", password);
    await prefs.setBool("logged_in", true);

    return true;
  }

  // ================= CHECK LOGIN =================
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool("logged_in") ?? false;
  }

  // ================= LOGOUT =================
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("logged_in", false);
  }

  // ================= FORCE LOGIN SAVE =================
  static Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool("logged_in", value);
  }
}