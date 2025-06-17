// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

/// 設定関連のデータアクセスを担当するRepository
class SettingsRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 現在のユーザー設定を取得
  Future<Map<String, dynamic>?> getUserSettings() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      // usersテーブルからはreflection_type_idのみ取得
      final response =
          await _supabase
              .from('users')
              .select('reflection_type_id')
              .eq('id', user.id)
              .maybeSingle();

      // 認証情報のemailも含めて返す
      final settings = response ?? <String, dynamic>{};
      settings['email'] = user.email; // 認証情報からemailを取得

      return settings;
    } catch (e) {
      throw Exception('ユーザー設定の取得に失敗しました: $e');
    }
  }

  /// リフレクション頻度を保存
  Future<void> saveReflectionFrequency(int reflectionTypeId) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      await _supabase
          .from('users')
          .update({
            'reflection_type_id': reflectionTypeId,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', user.id);
    } catch (e) {
      throw Exception('リフレクション頻度の保存に失敗しました: $e');
    }
  }

  /// その他のユーザー設定を保存
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      await _supabase
          .from('users')
          .update({
            ...preferences,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', user.id);
    } catch (e) {
      throw Exception('設定の保存に失敗しました: $e');
    }
  }
}
