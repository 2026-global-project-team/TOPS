import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../Screen/Archive/models/story.dart';

class StoryService {
  StoryService._();

  static final SupabaseClient _supabase =
      Supabase.instance.client;

  static const String _storyImageBucket =
      'story-images';

  static Future<int> createStory({
    required String title,
    required String content,
    required int placeId,
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

    int? createdStoryId;

    final List<String> uploadedImagePaths =
    <String>[];

    try {
      debugPrint(
        'STEP 1: stories 테이블 저장 시작',
      );

      /*
       * 실제 stories 테이블 컬럼:
       *
       * user_id
       * place_id
       * title
       * content
       * location
       * visited_at
       *
       * created_at, updated_at은 DB 기본값을 사용하므로
       * Flutter에서 직접 넣지 않는다.
       */
      final Map<String, dynamic> storyRow =
      await _supabase
          .from('stories')
          .insert({
        'user_id': user.id,
        'place_id': placeId,
        'title': title,
        'content': content,
        'location': location,
        'visited_at':
        visitedAt.toIso8601String(),
      })
          .select('id')
          .single();

      createdStoryId =
          (storyRow['id'] as num).toInt();

      debugPrint(
        'STEP 1 완료: storyId = $createdStoryId',
      );

      /*
       * 선택된 사진을 순서대로 Storage에 업로드하고
       * story_images 테이블에 저장한다.
       */
      for (
      int index = 0;
      index < images.length;
      index++
      ) {
        final File imageFile =
        images[index];

        final String fileName =
            '${DateTime.now().microsecondsSinceEpoch}_$index.jpg';

        final String storagePath =
            '${user.id}/$createdStoryId/$fileName';

        debugPrint(
          'STEP 2: Storage 업로드 시작 '
              '($storagePath)',
        );

        await _supabase.storage
            .from(_storyImageBucket)
            .upload(
          storagePath,
          imageFile,
          fileOptions:
          const FileOptions(
            cacheControl: '3600',
            upsert: false,
            contentType: 'image/jpeg',
          ),
        );

        uploadedImagePaths.add(
          storagePath,
        );

        debugPrint(
          'STEP 2 완료: $storagePath',
        );

        debugPrint(
          'STEP 3: story_images 저장 시작',
        );

        /*
         * 실제 story_images 컬럼:
         *
         * story_id
         * image_path
         * display_order
         *
         * 이전에 사용했던 sort_order는
         * 실제 테이블에 존재하지 않는다.
         */
        await _supabase
            .from('story_images')
            .insert({
          'story_id': createdStoryId,
          'image_path': storagePath,

          // DB의 순서 값은 1부터 시작
          'display_order': index + 1,
        });

        debugPrint(
          'STEP 3 완료: image index = $index',
        );
      }

      return createdStoryId;
    } catch (error, stackTrace) {
      debugPrint(
        'Create story error: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );

      /*
       * 사진 업로드 도중 실패했다면
       * 이미 업로드된 Storage 파일을 삭제한다.
       */
      if (uploadedImagePaths.isNotEmpty) {
        try {
          await _supabase.storage
              .from(_storyImageBucket)
              .remove(
            uploadedImagePaths,
          );
        } catch (cleanupError) {
          debugPrint(
            'Storage cleanup error: '
                '$cleanupError',
          );
        }
      }

      /*
       * Story 생성 후 사진 저장 과정에서 실패했다면
       * 생성된 stories 행도 삭제한다.
       *
       * story_images에 외래키 cascade 삭제가 설정돼 있다면
       * 연결된 사진 행도 자동 삭제될 수 있다.
       */
      if (createdStoryId != null) {
        try {
          await _supabase
              .from('stories')
              .delete()
              .eq(
            'id',
            createdStoryId,
          );
        } catch (cleanupError) {
          debugPrint(
            'Story cleanup error: '
                '$cleanupError',
          );
        }
      }

      rethrow;
    }
  }
  static Future<List<Story>> getCurrentUserStories() async {
    final User? user = _supabase.auth.currentUser;

    if (user == null) {
      throw const AuthException(
        'You must be logged in.',
      );
    }

    final List<dynamic> rows =
    await _supabase
        .from('stories')
        .select('''
            id,
            place_id,
            title,
            content,
            location,
            visited_at,
            story_images (
              image_path,
              display_order
            )
          ''')
        .eq('user_id', user.id)
        .order(
      'visited_at',
      ascending: false,
    );

    final List<Story> stories = [];

    for (final dynamic row in rows) {
      final Map<String, dynamic> data =
      Map<String, dynamic>.from(
        row as Map,
      );

      final List<dynamic> rawImages =
      data['story_images'] is List
          ? List<dynamic>.from(
        data['story_images'],
      )
          : <dynamic>[];

      rawImages.sort(
            (dynamic a, dynamic b) {
          final Map<String, dynamic> first =
          Map<String, dynamic>.from(
            a as Map,
          );

          final Map<String, dynamic> second =
          Map<String, dynamic>.from(
            b as Map,
          );

          final int firstOrder =
              (first['display_order'] as num?)
                  ?.toInt() ??
                  0;

          final int secondOrder =
              (second['display_order'] as num?)
                  ?.toInt() ??
                  0;

          return firstOrder.compareTo(
            secondOrder,
          );
        },
      );

      final List<String> imageUrls = [];

      for (final dynamic rawImage in rawImages) {
        final Map<String, dynamic> image =
        Map<String, dynamic>.from(
          rawImage as Map,
        );

        final String imagePath =
            image['image_path']
                ?.toString()
                .trim() ??
                '';

        if (imagePath.isEmpty) {
          continue;
        }

        final String signedUrl =
        await _supabase.storage
            .from(_storyImageBucket)
            .createSignedUrl(
          imagePath,
          60 * 60,
        );

        imageUrls.add(signedUrl);
      }

      stories.add(
        Story(
          id: (data['id'] as num).toInt(),
          placeId:
          (data['place_id'] as num).toInt(),
          title:
          data['title']?.toString() ?? '',
          content:
          data['content']?.toString() ?? '',
          location:
          data['location']?.toString() ?? '',
          visitedAt: DateTime.parse(
            data['visited_at'].toString(),
          ).toLocal(),
          imageUrls: imageUrls,
        ),
      );
    }

    return stories;
  }
}