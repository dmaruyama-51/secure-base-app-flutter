// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

class UserRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 現在のユーザーの作成日を取得
  Future<DateTime> getUserCreatedAt() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      final response =
          await _supabase
              .from('users')
              .select('created_at')
              .eq('id', user.id)
              .single();

      return DateTime.parse(response['created_at']);
    } catch (e) {
      throw Exception('ユーザー情報の取得に失敗しました: $e');
    }
  }

  /// 現在のユーザー情報を取得
  Future<Map<String, dynamic>?> getCurrentUserInfo() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return null;
      }

      final response =
          await _supabase
              .from('users')
              .select('*')
              .eq('id', user.id)
              .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('ユーザー情報の取得に失敗しました: $e');
    }
  }

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

  /// リフレクション頻度を更新（settings_repositoryの機能を統合）
  Future<void> updateReflectionFrequency(int reflectionTypeId) async {
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
      throw Exception('リフレクション頻度の更新に失敗しました: $e');
    }
  }

  /// ユーザー設定を更新（settings_repositoryの機能を統合）
  Future<void> updateUserPreferences(Map<String, dynamic> preferences) async {
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
      throw Exception('ユーザー設定の更新に失敗しました: $e');
    }
  }
}
