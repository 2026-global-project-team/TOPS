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
    final String normalizedUserName =
    userName.trim().isEmpty
        ? 'TOPS Traveler'
        : userName.trim();

    final String normalizedLocation =
    location.trim().isEmpty
        ? 'London'
        : location.trim();

    await _supabase.from('profiles').upsert(
      {
        'id': userId,
        'user_name': normalizedUserName,
        'level_name': 'City Wanderer',
        'location': normalizedLocation,
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
      userName: userName,
      location: location,
    );
  }

  static Future<void>
  createSocialProfileIfNeeded() async {
    final User? user = currentUser;

    if (user == null) {
      throw const AuthException(
        'You must be logged in.',
      );
    }

    final Map<String, dynamic> metadata =
        user.userMetadata ?? <String, dynamic>{};

    final String userName = _getSocialUserName(
      user: user,
      metadata: metadata,
    );

    final String location =
    metadata['location']?.toString().trim().isNotEmpty ==
        true
        ? metadata['location'].toString().trim()
        : 'London';

    await _createProfileIfNeeded(
      userId: user.id,
      userName: userName,
      location: location,
    );
  }

  static String _getSocialUserName({
    required User user,
    required Map<String, dynamic> metadata,
  }) {
    final List<dynamic> candidates = [
      metadata['user_name'],
      metadata['full_name'],
      metadata['name'],
      metadata['preferred_username'],
      metadata['given_name'],
    ];

    for (final dynamic candidate in candidates) {
      final String value =
          candidate?.toString().trim() ?? '';

      if (value.isNotEmpty) {
        return value;
      }
    }

    final String email =
        user.email?.trim() ?? '';

    if (email.contains('@')) {
      final String emailName =
      email.split('@').first.trim();

      if (emailName.isNotEmpty) {
        return emailName;
      }
    }

    return 'TOPS Traveler';
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