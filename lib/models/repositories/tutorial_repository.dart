// Package imports:
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TutorialRepository {
  static const String _hasCompletedTutorialKey = 'has_completed_tutorial';
  final SupabaseClient _supabase = Supabase.instance.client;

  /// チュートリアルが完了しているかを確認
  Future<bool> hasCompletedTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasCompletedTutorialKey) ?? false;
  }

  /// チュートリアル完了をマーク
  Future<void> markTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedTutorialKey, true);
  }

  /// リフレクション頻度をDBに保存
  Future<void> saveReflectionFrequency(String frequency) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('ユーザーが認証されていません');
    }

    // 頻度から反映タイプIDに変換
    final reflectionTypeId = _getReflectionTypeId(frequency);

    try {
      // ユーザーテーブルのreflection_type_idを更新
      await _supabase
          .from('users')
          .update({
            'reflection_type_id': reflectionTypeId,
            // DBに保存するタイムゾーンはUTC
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', user.id);
    } catch (e) {
      throw Exception('リフレクション頻度の保存に失敗しました: $e');
    }
  }

  /// 頻度文字列からreflection_type_idに変換
  int _getReflectionTypeId(String frequency) {
    switch (frequency) {
      case '週に1回':
        return 3;
      case '2週に1回':
        return 2;
      case '月に1回':
        return 1;
      default:
        return 2; // デフォルトは「2週に1回」
    }
  }
}
