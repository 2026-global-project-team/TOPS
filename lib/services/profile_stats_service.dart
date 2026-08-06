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

  const ProfileStatsData.empty()
      : placeCount = 0,
        photoCount = 0,
        wishCount = 0;
}

class ProfileStatsService {
  ProfileStatsService._();

  static final SupabaseClient _supabase =
      Supabase.instance.client;

  static Future<ProfileStatsData>
  getCurrentUserStats() async {
    final User? user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException(
        'You must be logged in.',
      );
    }

    final String userId = user.id;

    /*
     * 중요:
     *
     * 아래 통계 쿼리는 현재 예상한 관계를 기준으로 작성했다.
     *
     * stories.user_id
     * stories.place_id
     * story_images.story_id
     * wishlist.user_id
     *
     * 실제 Supabase 컬럼명이 다르면
     * 해당 컬럼명만 실제 스키마에 맞게 변경해야 한다.
     */

    final List<dynamic> storyRows =
    await _supabase
        .from('stories')
        .select('id, place_id')
        .eq('user_id', userId);

    final List<Map<String, dynamic>> stories =
    storyRows
        .map(
          (dynamic row) =>
      Map<String, dynamic>.from(
        row as Map,
      ),
    )
        .toList();

    final Set<String> placeIds = stories
        .map(
          (Map<String, dynamic> story) =>
      story['place_id']
          ?.toString()
          .trim() ??
          '',
    )
        .where(
          (String id) => id.isNotEmpty,
    )
        .toSet();

    final int placeCount = placeIds.length;

    final List<String> storyIds = stories
        .map(
          (Map<String, dynamic> story) =>
      story['id']?.toString().trim() ??
          '',
    )
        .where(
          (String id) => id.isNotEmpty,
    )
        .toList();

    int photoCount = 0;

    if (storyIds.isNotEmpty) {
      final List<dynamic> imageRows =
      await _supabase
          .from('story_images')
          .select('id')
          .inFilter(
        'story_id',
        storyIds,
      );

      photoCount = imageRows.length;
    }

    final List<dynamic> wishRows =
    await _supabase
        .from('wishlist')
        .select('id')
        .eq('user_id', userId);

    final int wishCount = wishRows.length;

    return ProfileStatsData(
      placeCount: placeCount,
      photoCount: photoCount,
      wishCount: wishCount,
    );
  }

  static Future<ProfileStatsData>
  getCurrentUserStatsSafely() async {
    try {
      return await getCurrentUserStats();
    } catch (error, stackTrace) {
      debugPrint(
        'Profile stats loading error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      /*
       * 통계 테이블 또는 컬럼 연결이 아직 맞지 않더라도
       * ProfilePage 전체가 비정상 화면이 되지 않게
       * 통계만 0으로 반환한다.
       */
      return const ProfileStatsData.empty();
    }
  }
}