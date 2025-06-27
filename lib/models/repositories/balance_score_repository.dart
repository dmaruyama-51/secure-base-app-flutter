// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../balance_score.dart';

class BalanceScoreRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// 現在のユーザーの週次バランススコアを取得（過去12週分）
  Future<List<BalanceScore>> fetchWeeklyBalanceScores({int limit = 12}) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('ユーザーがログインしていません');
      }

      final response = await _supabase
          .from('balance_scores')
          .select('*')
          .eq('user_id', currentUser.id)
          .order('week_start_date', ascending: true);

      if (response.isEmpty) {
        // 空のリストを返す（エラーではない）
        return [];
      }

      final allBalanceScores =
          response.map((data) => BalanceScore.fromJson(data)).toList();

      // 最新のlimit件を取得（リストの末尾から）
      final startIndex =
          allBalanceScores.length > limit ? allBalanceScores.length - limit : 0;
      return allBalanceScores.sublist(startIndex);
    } catch (e) {
      throw Exception('バランススコアの取得に失敗しました: $e');
    }
  }
}
