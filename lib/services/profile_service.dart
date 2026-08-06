import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileData {
  final String userName;
  final String location;
  final String? profileImageUrl;

  const ProfileData({
    required this.userName,
    required this.location,
    required this.profileImageUrl,
  });
}

class ProfileService {
  ProfileService._();

  static final SupabaseClient _supabase =
      Supabase.instance.client;

  static Future<ProfileData> getCurrentProfile() async {
    final User? user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException(
        'You must be logged in.',
      );
    }

    final Map<String, dynamic>? profile =
    await _supabase
        .from('profiles')
        .select(
      'user_name, location, city, profile_image_url',
    )
        .eq('id', user.id)
        .maybeSingle();

    final Map<String, dynamic> metadata =
        user.userMetadata ?? <String, dynamic>{};

    final String userName = _firstNonEmpty(
      [
        profile?['user_name'],
        metadata['user_name'],
        metadata['full_name'],
        metadata['name'],
        user.email?.split('@').first,
      ],
      fallback: 'TOPS Traveler',
    );

    final String location = _firstNonEmpty(
      [
        profile?['city'],
        profile?['location'],
        metadata['location'],
      ],
      fallback: 'London',
    );

    final String? profileImageUrl =
    _firstNonEmptyOrNull(
      [
        profile?['profile_image_url'],
        metadata['avatar_url'],
        metadata['picture'],
      ],
    );

    return ProfileData(
      userName: userName,
      location: location,
      profileImageUrl: profileImageUrl,
    );
  }

  static Future<String> getCurrentUserName() async {
    final ProfileData profile =
    await getCurrentProfile();

    return profile.userName;
  }

  static String _firstNonEmpty(
      List<dynamic> values, {
        required String fallback,
      }) {
    for (final dynamic value in values) {
      final String text =
          value?.toString().trim() ?? '';

      if (text.isNotEmpty) {
        return text;
      }
    }

    return fallback;
  }

  static String? _firstNonEmptyOrNull(
      List<dynamic> values,
      ) {
    for (final dynamic value in values) {
      final String text =
          value?.toString().trim() ?? '';

      if (text.isNotEmpty) {
        return text;
      }
    }

    return null;
  }
}