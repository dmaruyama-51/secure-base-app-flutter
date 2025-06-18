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
}
