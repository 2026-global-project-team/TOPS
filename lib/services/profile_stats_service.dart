import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileStatsData {
  final int placeCount;
  final int photoCount;
  final int wishCount;

  const ProfileStatsData({
    required this.placeCount,
    required this.photoCount,
    required this.wishCount,
  });
}

class ProfileStatsService {
  ProfileStatsService._();

  static final SupabaseClient _supabase =
      Supabase.instance.client;

  static Future<ProfileStatsData>
  getCurrentUserStats() async {
    final User? user =
        _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException(
        'You must be logged in.',
      );
    }

    final String userId = user.id;

    // 1. 현재 사용자의 stories 조회
    final List<dynamic> storyRows =
    await _supabase
        .from('stories')
        .select('id, place_id')
        .eq('user_id', userId);

    final List<Map<String, dynamic>> stories =
    storyRows.map((dynamic row) {
      return Map<String, dynamic>.from(
        row as Map,
      );
    }).toList();

    // 동일한 장소에 여러 Archive가 있어도
    // Places는 한 번만 계산
    final Set<int> uniquePlaceIds = stories
        .map((Map<String, dynamic> story) {
      final dynamic value =
      story['place_id'];

      if (value is num) {
        return value.toInt();
      }

      return int.tryParse(
        value?.toString() ?? '',
      );
    })
        .whereType<int>()
        .toSet();

    final int placeCount =
        uniquePlaceIds.length;

    // 2. 현재 사용자의 story ID 목록
    final List<int> storyIds = stories
        .map((Map<String, dynamic> story) {
      final dynamic value = story['id'];

      if (value is num) {
        return value.toInt();
      }

      return int.tryParse(
        value?.toString() ?? '',
      );
    })
        .whereType<int>()
        .toList();

    // 3. story_images 개수 조회
    int photoCount = 0;

    if (storyIds.isNotEmpty) {
      final List<dynamic> imageRows =
      await _supabase
          .from('story_images')
          .select('story_id')
          .inFilter(
        'story_id',
        storyIds,
      );

      photoCount = imageRows.length;
    }

    // 4. wishlist 개수 조회
    final List<dynamic> wishRows =
    await _supabase
        .from('wishlist')
        .select('place_id')
        .eq('user_id', userId);

    final int wishCount =
        wishRows.length;

    debugPrint(
      'Profile stats → '
          'places: $placeCount, '
          'photos: $photoCount, '
          'wish: $wishCount',
    );

    return ProfileStatsData(
      placeCount: placeCount,
      photoCount: photoCount,
      wishCount: wishCount,
    );
  }
}