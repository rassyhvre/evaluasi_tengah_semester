import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  Future<bool> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 1)); // simulasi loading

    if (email == "admin@gmail.com" && password == "123456") {

      // 🔥 token palsu
      String fakeToken = "dummy_token_123456";

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', fakeToken);

      print("Login berhasil, token: $fakeToken");

      return true;
    } else {
      print("Login gagal");
      return false;
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }
}