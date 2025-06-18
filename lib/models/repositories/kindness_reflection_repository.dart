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

  /// 現在のユーザーのリフレクション期間設定を取得
  Future<int> getReflectionPeriod() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      // kindness_reflectionsとreflection_type_masterをJOINして取得
      final response =
          await _supabase
              .from('kindness_reflections')
              .select('''
            reflection_type_id,
            reflection_type_master:reflection_type_id (
              reflection_period,
              reflection_type_name
            )
          ''')
              .eq('user_id', user.id)
              .order('created_at', ascending: false)
              .limit(1)
              .maybeSingle();

      if (response == null) {
        // リフレクションがない場合はデフォルト（週に1回=7日）
        return 7;
      }

      final masterInfo = response['reflection_type_master'];
      if (masterInfo == null) {
        return 7;
      }

      final period = masterInfo['reflection_period'] as int?;
      return period ?? 7;
    } catch (e) {
      // エラー時はデフォルト値を返す
      return 7;
    }
  }
}
