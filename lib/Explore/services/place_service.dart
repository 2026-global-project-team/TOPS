import 'package:supabase_flutter/supabase_flutter.dart';

class PlaceService {
  final SupabaseClient _supabase =
      Supabase.instance.client;

  Future<List<Map<String, dynamic>>>
  getPlaces() async {
    final response = await _supabase
        .from('places')
        .select()
        .order('id');

    return List<Map<String, dynamic>>.from(
      response,
    );
  }
}