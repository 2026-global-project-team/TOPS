import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
  AuthService._();

  static final SupabaseClient _supabase =
      Supabase.instance.client;

  static Future<bool> signInWithGoogle() async {
    return await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'com.tops.app://login-callback/',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }

  static Future<bool> signInWithApple() async {
    return await _supabase.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo: 'com.tops.app://login-callback/',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  }
}