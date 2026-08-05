import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PlaceService {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getPlaces() async {
    try {
      final response = await _supabase
          .from('places')
          .select()
          .order('id');

      debugPrint('places 응답: $response');
      debugPrint('places 개수: ${response.length}');
      debugPrint(
        '현재 사용자: ${_supabase.auth.currentUser?.email}',
      );

      return List<Map<String, dynamic>>.from(response);
    } catch (error, stackTrace) {
      debugPrint('places 조회 오류: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }
}