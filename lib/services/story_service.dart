import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/story.dart';

class StoryService {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<int> createStory({
    required String title,
    required String content,
    required String location,
    required DateTime visitedAt,
    required List<XFile> images,
    int? placeId,
  }) async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      throw Exception('로그인이 필요합니다.');
    }

    if (images.isEmpty) {
      throw Exception('사진을 최소 1장 선택해 주세요.');
    }

    if (images.length > 3) {
      throw Exception('사진은 최대 3장까지 선택할 수 있습니다.');
    }

    int? storyId;
    final uploadedPaths = <String>[];

    try {
      // 1. Story 먼저 저장하고 ID 받기
      final storyResponse = await _supabase
          .from('stories')
          .insert({
        'user_id': user.id,
        'place_id': placeId,
        'title': title.trim(),
        'content': content.trim(),
        'location': location.trim(),
        'visited_at': visitedAt.toIso8601String(),
      })
          .select('id')
          .single();

      storyId = storyResponse['id'] as int;

      // 2. 사진 1~3장 업로드
      for (int index = 0; index < images.length; index++) {
        final image = images[index];
        final displayOrder = index + 1;

        final extension = _getExtension(image.path);

        final imagePath =
            '${user.id}/$storyId/'
            '${DateTime.now().microsecondsSinceEpoch}'
            '_$displayOrder.$extension';

        await _supabase.storage
            .from('story-images')
            .upload(
          imagePath,
          File(image.path),
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
          ),
        );

        uploadedPaths.add(imagePath);

        // 3. 업로드 경로를 story_images에 저장
        await _supabase.from('story_images').insert({
          'story_id': storyId,
          'image_path': imagePath,
          'display_order': displayOrder,
        });
      }

      return storyId;
    } catch (error) {
      // 중간 실패 시 이미 업로드된 파일 정리
      if (uploadedPaths.isNotEmpty) {
        try {
          await _supabase.storage
              .from('story-images')
              .remove(uploadedPaths);
        } catch (_) {}
      }

      // 생성된 Story도 정리
      if (storyId != null) {
        try {
          await _supabase
              .from('stories')
              .delete()
              .eq('id', storyId);
        } catch (_) {}
      }

      rethrow;
    }
  }

  Future<List<Story>> getMyStories() async {
    final user = _supabase.auth.currentUser;

    if (user == null) {
      return [];
    }

    final response = await _supabase
        .from('stories')
        .select('''
          id,
          user_id,
          place_id,
          title,
          content,
          location,
          visited_at,
          created_at,
          story_images (
            id,
            image_path,
            display_order
          )
        ''')
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return (response as List<dynamic>)
        .map(
          (json) => Story.fromJson(
        json as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  Future<String> createImageUrl(
      String imagePath,
      ) async {
    return _supabase.storage
        .from('story-images')
        .createSignedUrl(
      imagePath,
      3600,
    );
  }

  String _getExtension(String path) {
    final parts = path.split('.');

    if (parts.length < 2) {
      return 'jpg';
    }

    final extension = parts.last.toLowerCase();

    if (extension == 'jpeg' ||
        extension == 'jpg' ||
        extension == 'png' ||
        extension == 'webp') {
      return extension;
    }

    return 'jpg';
  }
}