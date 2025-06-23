// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../kindness_record.dart';

class KindnessRecordRepository {
  Future<List<KindnessRecord>> fetchKindnessRecords({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      // 現在のユーザーを取得
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('ユーザーがログインしていません');
      }

      // ページネーション機能を追加してパフォーマンス向上
      final response = await Supabase.instance.client
          .from('kindness_records')
          .select('''
            *,
            kindness_givers:giver_id (
              giver_name,
              is_archived,
              relationship_master:relationship_id (name),
              gender_master:gender_id (name)
            )
          ''')
          .eq('user_id', currentUser.id)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      List<KindnessRecord> records = [];

      for (final data in response) {
        final giver = data['kindness_givers'];

        // アーカイブされたメンバーのレコードは除外
        if (giver != null && giver['is_archived'] == true) {
          continue;
        }

        records.add(
          KindnessRecord(
            id: data['id'],
            userId: data['user_id'],
            giverId: data['giver_id'],
            content: data['content'],
            createdAt: DateTime.parse(data['created_at']),
            updatedAt: DateTime.parse(data['updated_at']),
            giverName: giver?['giver_name'] ?? '不明',
            giverAvatarUrl: null, // avatar_urlカラムが存在しないためnull
            giverCategory: giver?['relationship_master']?['name'] ?? '',
            giverGender: giver?['gender_master']?['name'] ?? '',
          ),
        );
      }

      return records;
    } catch (e) {
      throw Exception('やさしさ記録の取得に失敗しました: $e');
    }
  }

  /// 記録の総数を取得（ページネーション用）
  Future<int> getKindnessRecordsCount() async {
    try {
      // 現在のユーザーを取得
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('ユーザーがログインしていません');
      }

      final response = await Supabase.instance.client
          .from('kindness_records')
          .select('''
            id,
            kindness_givers:giver_id (is_archived)
          ''')
          .eq('user_id', currentUser.id);

      // アーカイブされていないメンバーのレコードのみカウント
      int count = 0;
      for (final data in response) {
        final giver = data['kindness_givers'];
        if (giver != null && giver['is_archived'] != true) {
          count++;
        }
      }

      return count;
    } catch (e) {
      // カウント取得に失敗した場合は0を返す
      return 0;
    }
  }

  Future<KindnessRecord?> fetchKindnessRecordById(int id) async {
    try {
      // 現在のユーザーを取得
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('ユーザーがログインしていません');
      }

      final response =
          await Supabase.instance.client
              .from('kindness_records')
              .select('''
            *,
            kindness_givers:giver_id (
              giver_name,
              is_archived,
              relationship_master:relationship_id (name),
              gender_master:gender_id (name)
            )
          ''')
              .eq('id', id)
              .eq('user_id', currentUser.id)
              .maybeSingle();

      if (response == null) return null;

      final giver = response['kindness_givers'];

      // アーカイブされたメンバーのレコードの場合はnullを返す
      if (giver != null && giver['is_archived'] == true) {
        return null;
      }

      return KindnessRecord(
        id: response['id'],
        userId: response['user_id'],
        giverId: response['giver_id'],
        content: response['content'],
        createdAt: DateTime.parse(response['created_at']),
        updatedAt: DateTime.parse(response['updated_at']),
        giverName: giver?['giver_name'] ?? '不明',
        giverAvatarUrl: null, // avatar_urlカラムが存在しないためnull
        giverCategory: giver?['relationship_master']?['name'] ?? '',
        giverGender: giver?['gender_master']?['name'] ?? '',
      );
    } catch (e) {
      throw Exception('やさしさ記録の取得に失敗しました: $e');
    }
  }

  Future<bool> saveKindnessRecord(KindnessRecord record) async {
    try {
      // 現在の時刻を取得
      final now = DateTime.now().toIso8601String();

      // IDは自動生成されるため明示的に除外し、created_atとupdated_atを同じ値に設定
      final insertData = {
        'user_id': record.userId,
        'giver_id': record.giverId,
        'content': record.content,
        'created_at': now,
        'updated_at': now,
      };

      await Supabase.instance.client
          .from('kindness_records')
          .insert(insertData);

      return true;
    } on PostgrestException catch (e) {
      // プライマリキー制約違反の場合は、より詳細なエラーメッセージを提供
      if (e.code == '23505' && e.message.contains('kindness_records_pkey')) {
        throw Exception(
          'データベースのシーケンスエラーが発生しました。管理者にお問い合わせください。（エラーコード: PK_VIOLATION）',
        );
      }
      throw Exception('やさしさ記録の保存に失敗しました: ${e.message}');
    } catch (e) {
      throw Exception('やさしさ記録の保存に失敗しました: $e');
    }
  }

  Future<bool> updateKindnessRecord(KindnessRecord record) async {
    try {
      // 現在のユーザーを取得
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('ユーザーがログインしていません');
      }

      await Supabase.instance.client
          .from('kindness_records')
          .update({
            'giver_id': record.giverId,
            'content': record.content,
            'updated_at': record.updatedAt.toIso8601String(),
          })
          .eq('id', record.id!)
          .eq('user_id', currentUser.id);
      return true;
    } catch (e) {
      throw Exception('やさしさ記録の更新に失敗しました: $e');
    }
  }

  Future<bool> deleteKindnessRecord(int id) async {
    try {
      // 現在のユーザーを取得
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('ユーザーがログインしていません');
      }

      await Supabase.instance.client
          .from('kindness_records')
          .delete()
          .eq('id', id)
          .eq('user_id', currentUser.id);
      return true;
    } catch (e) {
      throw Exception('やさしさ記録の削除に失敗しました: $e');
    }
  }
}
