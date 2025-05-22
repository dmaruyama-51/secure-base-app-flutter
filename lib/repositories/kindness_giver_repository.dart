import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kindness_giver.dart';

class KindnessGiverRepository {
  final _supabase = Supabase.instance.client;

  /// 現在ログインしているユーザーのIDを取得
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// kindness_giversテーブルから現在のユーザーのデータを取得
  Future<List<KindnessGiver>> fetchKindnessGivers() async {
    try {
      // ユーザーIDがない場合は空のリストを返す
      final userId = _currentUserId;
      if (userId == null) {
        return [];
      }

      // kindness_giversテーブルから現在のユーザーのデータを取得
      final kindnessGiversResponse = await _supabase
          .from('kindness_givers')
          .select()
          .eq('user_id', userId)
          .order('id');

      // マスターデータを取得
      final relationshipMasterResponse = await _supabase
          .from('relationship_master')
          .select()
          .order('id');

      final genderMasterResponse = await _supabase
          .from('gender_master')
          .select()
          .order('id');

      // マスターデータをマップに変換して処理を高速化
      final relationshipMap = {
        for (var relationship in relationshipMasterResponse)
          relationship['id'] as int: relationship['name'] as String,
      };

      final genderMap = {
        for (var gender in genderMasterResponse)
          gender['id'] as int: gender['name'] as String,
      };

      // kindness_giversのデータを変換
      return kindnessGiversResponse.map<KindnessGiver>((data) {
        return KindnessGiver.fromMap(
          data,
          relationshipName: relationshipMap[data['relationship_id']] ?? '不明',
          genderName: genderMap[data['gender_id']] ?? '不明',
        );
      }).toList();
    } catch (e) {
      // エラーが発生した場合は空のリストを返す
      print('エラー発生: $e');
      return [];
    }
  }

  /// メンバー新規作成
  Future<bool> createKindnessGiver(KindnessGiver kindnessGiver) async {
    try {
      // ユーザーIDがない場合は保存できない
      final userId = _currentUserId;
      if (userId == null) {
        return false;
      }

      final data = kindnessGiver.toMap();
      // 現在のユーザーIDを設定
      data['user_id'] = userId;

      // 新規データの追加
      await _supabase.from('kindness_givers').insert(data);
      return true;
    } catch (e) {
      print('作成エラー: $e');
      return false;
    }
  }

  /// 優しさをくれる人を更新する
  Future<bool> updateKindnessGiver(KindnessGiver kindnessGiver) async {
    try {
      // ユーザーIDがない場合は更新できない
      final userId = _currentUserId;
      if (userId == null) {
        return false;
      }

      // IDがない場合は更新できない
      if (kindnessGiver.id == null) {
        print('更新エラー: IDがありません。');
        return false;
      }

      final data = kindnessGiver.toMap();
      // 現在のユーザーIDを設定（念のため）
      data['user_id'] = userId;

      // 既存データの更新（自分のデータのみ更新可能）
      await _supabase
          .from('kindness_givers')
          .update(data)
          .eq('id', kindnessGiver.id as int)
          .eq('user_id', userId);
      return true;
    } catch (e) {
      print('更新エラー: $e');
      return false;
    }
  }

  /// relationship_masterテーブルからデータを取得
  Future<List<Map<String, dynamic>>> fetchRelationships() async {
    try {
      final response = await _supabase
          .from('relationship_master')
          .select()
          .order('id');
      return response;
    } catch (e) {
      print('関係性マスター取得エラー: $e');
      return [];
    }
  }

  /// gender_masterテーブルからデータを取得
  Future<List<Map<String, dynamic>>> fetchGenders() async {
    try {
      final response = await _supabase
          .from('gender_master')
          .select()
          .order('id');
      return response;
    } catch (e) {
      print('性別マスター取得エラー: $e');
      return [];
    }
  }

  /// メンバー削除
  Future<bool> deleteKindnessGiver(int kindnessGiverId) async {
    try {
      // ユーザーIDがない場合は削除できない
      final userId = _currentUserId;
      if (userId == null) {
        return false;
      }

      // 自分のデータのみ削除可能
      await _supabase
          .from('kindness_givers')
          .delete()
          .eq('id', kindnessGiverId)
          .eq('user_id', userId);
      return true;
    } catch (e) {
      print('削除エラー: $e');
      return false;
    }
  }
}
