import 'package:supabase_flutter/supabase_flutter.dart';

import '../Screen/Archive/models/story.dart';
import 'story_service.dart';

class WishService {
  WishService._();

  static final SupabaseClient _supabase =
      Supabase.instance.client;

  static User _requireUser() {
    final User? user =
        _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException(
        'You must be logged in.',
      );
    }

    return user;
  }

  static Future<Set<int>>
  getWishedStoryIds() async {
    final User user = _requireUser();

    final List<dynamic> rows =
    await _supabase
        .from('story_wishlist')
        .select('story_id')
        .eq('user_id', user.id);

    return rows
        .map((dynamic row) {
      final Map<String, dynamic> data =
      Map<String, dynamic>.from(
        row as Map,
      );

      final dynamic storyId =
      data['story_id'];

      if (storyId is num) {
        return storyId.toInt();
      }

      return int.tryParse(
        storyId?.toString() ?? '',
      );
    })
        .whereType<int>()
        .toSet();
  }

  // ============================================================
  // 장소 Wish 목록 조회
  // wishlist.place_id → places.id
  // ============================================================

  static Future<List<Map<String, dynamic>>>
  getWishedPlaces() async {
    final User user = _requireUser();

    final List<dynamic> rows =
    await _supabase
        .from('wishlist')
        .select('''
              place_id,
              created_at,
              places (
                id,
                name,
                category,
                description,
                address,
                city,
                latitude,
                longitude,
                image_url
              )
            ''')
        .eq('user_id', user.id)
        .order(
      'created_at',
      ascending: false,
    );

    return rows
        .map((dynamic row) {
      final Map<String, dynamic> data =
      Map<String, dynamic>.from(
        row as Map,
      );

      final dynamic rawPlace =
      data['places'];

      if (rawPlace is! Map) {
        return null;
      }

      final Map<String, dynamic> place =
      Map<String, dynamic>.from(
        rawPlace,
      );

      place['is_wish'] = true;

      return place;
    })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  // ============================================================
  // Story Wish 목록 조회
  //
  // Story 자체와 사진 Signed URL 생성은
  // 기존 StoryService가 담당한다.
  // ============================================================

  static Future<List<Story>>
  getWishedStories() async {
    final User user = _requireUser();

    final List<dynamic> wishRows =
    await _supabase
        .from('story_wishlist')
        .select('story_id')
        .eq('user_id', user.id);

    final Set<int> wishedStoryIds =
    wishRows
        .map((dynamic row) {
      final Map<String, dynamic> data =
      Map<String, dynamic>.from(
        row as Map,
      );

      final dynamic value =
      data['story_id'];

      if (value is num) {
        return value.toInt();
      }

      return int.tryParse(
        value?.toString() ?? '',
      );
    })
        .whereType<int>()
        .toSet();

    if (wishedStoryIds.isEmpty) {
      return <Story>[];
    }

    final List<Story> allStories =
    await StoryService
        .getCurrentUserStories();

    return allStories
        .where(
          (Story story) =>
          wishedStoryIds.contains(
            story.id,
          ),
    )
        .map(
          (Story story) =>
          story.copyWith(
            isWish: true,
          ),
    )
        .toList();
  }

  // ============================================================
  // 장소 하트 상태 확인
  // ============================================================

  static Future<bool> isPlaceWished(
      int placeId,
      ) async {
    final User user = _requireUser();

    final Map<String, dynamic>? row =
    await _supabase
        .from('wishlist')
        .select('place_id')
        .eq('user_id', user.id)
        .eq('place_id', placeId)
        .maybeSingle();

    return row != null;
  }

  // ============================================================
  // Story 하트 상태 확인
  // ============================================================

  static Future<bool> isStoryWished(
      int storyId,
      ) async {
    final User user = _requireUser();

    final Map<String, dynamic>? row =
    await _supabase
        .from('story_wishlist')
        .select('id')
        .eq('user_id', user.id)
        .eq('story_id', storyId)
        .maybeSingle();

    return row != null;
  }

  // ============================================================
  // 장소 Wish 추가/해제
  //
  // 반환값:
  // true  → 추가됨
  // false → 해제됨
  // ============================================================

  static Future<bool> togglePlaceWish(
      int placeId,
      ) async {
    final User user = _requireUser();

    final bool alreadyWished =
    await isPlaceWished(placeId);

    if (alreadyWished) {
      await removePlaceWish(placeId);
      return false;
    }

    await _supabase
        .from('wishlist')
        .insert({
      'user_id': user.id,
      'place_id': placeId,
    });

    return true;
  }

  // ============================================================
  // Story Wish 추가/해제
  // ============================================================

  static Future<bool> toggleStoryWish(
      int storyId,
      ) async {
    final User user = _requireUser();

    final bool alreadyWished =
    await isStoryWished(storyId);

    if (alreadyWished) {
      await removeStoryWish(storyId);
      return false;
    }

    await _supabase
        .from('story_wishlist')
        .insert({
      'user_id': user.id,
      'story_id': storyId,
    });

    return true;
  }

  static Future<void> removePlaceWish(
      int placeId,
      ) async {
    final User user = _requireUser();

    await _supabase
        .from('wishlist')
        .delete()
        .eq('user_id', user.id)
        .eq('place_id', placeId);
  }

  static Future<void> removeStoryWish(
      int storyId,
      ) async {
    final User user = _requireUser();

    await _supabase
        .from('story_wishlist')
        .delete()
        .eq('user_id', user.id)
        .eq('story_id', storyId);
  }
}