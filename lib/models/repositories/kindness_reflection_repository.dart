// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../kindness_reflection.dart';

class KindnessReflectionRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 現在のユーザーのリフレクション一覧を取得
  Future<List<KindnessReflection>> fetchReflections({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      final response = await _supabase
          .from('kindness_reflections')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      return response
          .map<KindnessReflection>((item) => KindnessReflection.fromMap(item))
          .toList();
    } catch (e) {
      throw Exception('リフレクション一覧の取得に失敗しました: $e');
    }
  }

  /// 特定のリフレクションを取得
  Future<KindnessReflection?> getReflectionById(int id) async {
    try {
      final response =
          await _supabase
              .from('kindness_reflections')
              .select()
              .eq('id', id)
              .maybeSingle();

      if (response == null) {
        return null;
      }

      return KindnessReflection.fromMap(response);
    } catch (e) {
      throw Exception('リフレクションの取得に失敗しました: $e');
    }
  }
}
