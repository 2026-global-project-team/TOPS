import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

class StoryService {
  StoryService._();

  static final SupabaseClient _supabase =
      Supabase.instance.client;

  static const String _storyImageBucket =
      'story-images';

  static Future<String> createStory({
    required String title,
    required String description,
    required String location,
    required DateTime visitedAt,
    required List<File> images,
  }) async {
    final User? user =
        _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException(
        'You must be logged in.',
      );
    }

    if (images.isEmpty) {
      throw Exception(
        'At least one image is required.',
      );
    }

    String? createdStoryId;
    final List<String> uploadedImagePaths = [];

    try {
      /*
       * 1. stories 테이블에 기록을 먼저 저장한다.
       *
       * 현재 아래 컬럼이 있다고 가정:
       * - user_id
       * - title
       * - description
       * - location
       * - visited_at
       *
       * 실제 컬럼명이 content라면:
       * 'description': description
       * 을
       * 'content': description
       * 으로 변경한다.
       */
      final Map<String, dynamic> storyRow =
      await _supabase
          .from('stories')
          .insert({
        'user_id': user.id,
        'title': title,
        'description': description,
        'location': location,
        'visited_at':
        visitedAt.toIso8601String(),
      })
          .select('id')
          .single();

      createdStoryId =
          storyRow['id'].toString();

      /*
       * 2. 선택한 사진을 Storage에 업로드한다.
       *
       * 저장 경로:
       * 사용자 ID / Story ID / 파일명
       */
      for (
      int index = 0;
      index < images.length;
      index++
      ) {
        final File imageFile = images[index];

        final String fileName =
            '${DateTime.now().microsecondsSinceEpoch}_$index.jpg';

        final String storagePath =
            '${user.id}/$createdStoryId/$fileName';

        await _supabase.storage
            .from(_storyImageBucket)
            .upload(
          storagePath,
          imageFile,
          fileOptions: const FileOptions(
            cacheControl: '3600',
            upsert: false,
            contentType: 'image/jpeg',
          ),
        );

        uploadedImagePaths.add(storagePath);

        /*
         * 3. 업로드한 사진 정보를 story_images에 저장한다.
         *
         * 현재 아래 컬럼이 있다고 가정:
         * - story_id
         * - image_path
         * - sort_order
         *
         * image_path 대신 storage_path 컬럼을 만들었다면
         * 아래 'image_path'만 'storage_path'로 변경한다.
         */
        await _supabase
            .from('story_images')
            .insert({
          'story_id': createdStoryId,
          'image_path': storagePath,
          'sort_order': index,
        });
      }

      return createdStoryId;
    } catch (error) {
      /*
       * 중간에 저장 실패 시 이미 업로드한 사진과
       * 생성된 story를 정리한다.
       */
      if (uploadedImagePaths.isNotEmpty) {
        try {
          await _supabase.storage
              .from(_storyImageBucket)
              .remove(uploadedImagePaths);
        } catch (_) {
          // Storage 정리 실패는 원래 오류를 덮지 않도록 무시
        }
      }

      if (createdStoryId != null) {
        try {
          await _supabase
              .from('stories')
              .delete()
              .eq('id', createdStoryId);
        } catch (_) {
          // Story 정리 실패는 원래 오류를 덮지 않도록 무시
        }
      }

      rethrow;
    }
  }
}