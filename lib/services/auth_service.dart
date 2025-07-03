import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final SupabaseClient _client = Supabase.instance.client;

  static Future<void> signUp(String email, String password) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Signup failed. Try again.');
    }
  }

  static Future<void> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.session == null) {
      throw Exception('Invalid login credentials.');
    }
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static User? getCurrentUser() {
    return _client.auth.currentUser;
  }
}
//done