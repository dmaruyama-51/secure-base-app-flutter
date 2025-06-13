// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../entities/gender_master.dart';
import '../entities/relationship_master.dart';
import '../kindness_giver.dart';

/// メンバーデータのリポジトリクラス
class KindnessGiverRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// メンバー一覧を取得（JOINしてマスターデータも取得）
  Future<List<KindnessGiver>> fetchKindnessGivers() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('ユーザーがログインしていません');
      }

      final response = await _supabase
          .from('kindness_givers')
          .select('''
            id,
            user_id,
            giver_name,
            relationship_id,
            gender_id,
            created_at,
            relationship_master!inner(name),
            gender_master!inner(name)
          ''')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false);

      return response.map((data) {
        return KindnessGiver.fromJson({
          ...data,
          'relationship_name': data['relationship_master']['name'],
          'gender_name': data['gender_master']['name'],
        });
      }).toList();
    } catch (e) {
      print('Error fetching kindness givers: $e');
      throw Exception('メンバー一覧の取得に失敗しました: ${e.toString()}');
    }
  }

  /// 性別マスターデータを取得
  Future<List<GenderMaster>> fetchGenderMaster() async {
    try {
      final response = await _supabase
          .from('gender_master')
          .select('*')
          .order('id');

      return response.map((data) => GenderMaster.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching gender master: $e');
      throw Exception('性別マスターデータの取得に失敗しました: ${e.toString()}');
    }
  }

  /// 関係性マスターデータを取得
  Future<List<RelationshipMaster>> fetchRelationshipMaster() async {
    try {
      final response = await _supabase
          .from('relationship_master')
          .select('*')
          .order('id');

      return response.map((data) => RelationshipMaster.fromJson(data)).toList();
    } catch (e) {
      print('Error fetching relationship master: $e');
      throw Exception('関係性マスターデータの取得に失敗しました: ${e.toString()}');
    }
  }

  /// メンバー新規作成
  Future<KindnessGiver> createKindnessGiver(KindnessGiver kindnessGiver) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('ユーザーがログインしていません');
      }

      final response =
          await _supabase
              .from('kindness_givers')
              .insert({
                'user_id': currentUser.id,
                'giver_name': kindnessGiver.giverName,
                'relationship_id': kindnessGiver.relationshipId,
                'gender_id': kindnessGiver.genderId,
              })
              .select('''
            id,
            user_id,
            giver_name,
            relationship_id,
            gender_id,
            created_at,
            relationship_master!inner(name),
            gender_master!inner(name)
          ''')
              .single();

      return KindnessGiver.fromJson({
        ...response,
        'relationship_name': response['relationship_master']['name'],
        'gender_name': response['gender_master']['name'],
      });
    } catch (e) {
      print('Error creating kindness giver: $e');
      throw Exception('メンバーの作成に失敗しました: ${e.toString()}');
    }
  }

  /// メンバー更新
  Future<bool> updateKindnessGiver(KindnessGiver kindnessGiver) async {
    try {
      if (kindnessGiver.id == null) {
        throw Exception('更新対象のIDが指定されていません');
      }

      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('ユーザーがログインしていません');
      }

      await _supabase
          .from('kindness_givers')
          .update({
            'giver_name': kindnessGiver.giverName,
            'relationship_id': kindnessGiver.relationshipId,
            'gender_id': kindnessGiver.genderId,
          })
          .eq('id', kindnessGiver.id!)
          .eq('user_id', currentUser.id);

      return true;
    } catch (e) {
      print('Error updating kindness giver: $e');
      throw Exception('メンバーの更新に失敗しました: ${e.toString()}');
    }
  }

  /// メンバー削除
  Future<bool> deleteKindnessGiver(int id) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) {
        throw Exception('ユーザーがログインしていません');
      }

      await _supabase
          .from('kindness_givers')
          .delete()
          .eq('id', id)
          .eq('user_id', currentUser.id);

      return true;
    } catch (e) {
      print('Error deleting kindness giver: $e');
      throw Exception('メンバーの削除に失敗しました: ${e.toString()}');
    }
  }

  /// 名前でマスターデータのIDを取得（性別）
  Future<int?> getGenderIdByName(String genderName) async {
    try {
      final response =
          await _supabase
              .from('gender_master')
              .select('id')
              .eq('name', genderName)
              .maybeSingle();

      return response?['id'] as int?;
    } catch (e) {
      print('Error getting gender id: $e');
      return null;
    }
  }

  /// 名前でマスターデータのIDを取得（関係性）
  Future<int?> getRelationshipIdByName(String relationshipName) async {
    try {
      final response =
          await _supabase
              .from('relationship_master')
              .select('id')
              .eq('name', relationshipName)
              .maybeSingle();

      return response?['id'] as int?;
    } catch (e) {
      print('Error getting relationship id: $e');
      return null;
    }
  }
}
