import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthService {
  AuthService._();

  static final SupabaseClient _supabase =
      Supabase.instance.client;

  static User? get currentUser =>
      _supabase.auth.currentUser;

  static Session? get currentSession =>
      _supabase.auth.currentSession;

  static Stream<AuthState> get authStateChanges =>
      _supabase.auth.onAuthStateChange;

  static Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return await _supabase.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );
  }

  static Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String userName,
    String location = 'London',
  }) async {
    final String normalizedEmail =
    email.trim().toLowerCase();

    final String normalizedUserName =
    userName.trim();

    final String normalizedLocation =
    location.trim().isEmpty
        ? 'London'
        : location.trim();

    final AuthResponse response =
    await _supabase.auth.signUp(
      email: normalizedEmail,
      password: password,
      data: {
        'user_name': normalizedUserName,
        'location': normalizedLocation,
      },
    );

    final User? user = response.user;

    if (user == null) {
      throw const AuthException(
        'The account could not be created.',
      );
    }

    /*
     * Confirm Email이 OFF인 경우:
     * 회원가입 직후 session이 생성되고 authenticated 상태이므로
     * profiles 테이블에 직접 저장할 수 있다.
     */
    if (response.session != null) {
      await _createProfileIfNeeded(
        userId: user.id,
        userName: normalizedUserName,
        location: normalizedLocation,
      );
    }

    return response;
  }

  static Future<void> _createProfileIfNeeded({
    required String userId,
    required String userName,
    required String location,
  }) async {
    await _supabase.from('profiles').upsert(
      {
        'id': userId,
        'user_name': userName,
        'level_name': 'City Wanderer',
        'location': location,
        'updated_at':
        DateTime.now().toIso8601String(),
      },
      onConflict: 'id',
    );
  }

  static Future<void> createMissingProfile({
    required String userName,
    String location = 'London',
  }) async {
    final User? user = currentUser;

    if (user == null) {
      throw const AuthException(
        'You must be logged in.',
      );
    }

    await _createProfileIfNeeded(
      userId: user.id,
      userName: userName.trim(),
      location: location.trim().isEmpty
          ? 'London'
          : location.trim(),
    );
  }

  static Future<bool> signInWithGoogle() async {
    return await _supabase.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo:
      'com.tops.app://login-callback/',
      authScreenLaunchMode:
      LaunchMode.externalApplication,
    );
  }

  static Future<bool> signInWithApple() async {
    return await _supabase.auth.signInWithOAuth(
      OAuthProvider.apple,
      redirectTo:
      'com.tops.app://login-callback/',
      authScreenLaunchMode:
      LaunchMode.externalApplication,
    );
  }

  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }
}