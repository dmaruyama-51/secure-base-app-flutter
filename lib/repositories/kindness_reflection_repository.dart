import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/kindness_reflection.dart';
import '../models/kindness_record.dart';

// Reflectionデータの取得を担当するRepository
class KindnessReflectionRepository {
  final _supabase = Supabase.instance.client;

  /// 現在ログインしているユーザーのIDを取得
  String? get _currentUserId => _supabase.auth.currentUser?.id;

  /// kindness_reflectionsテーブルから現在のユーザーのデータを取得
  Future<List<KindnessReflection>> fetchKindnessReflections() async {
    try {
      // ユーザーIDがない場合は空のリストを返す
      final userId = _currentUserId;
      if (userId == null) {
        return [];
      }

      // kindness_reflectionsテーブルから現在のユーザーのデータを取得（reflection_type_masterとJOIN）
      final reflectionsResponse = await _supabase
          .from('kindness_reflections')
          .select('''
            id,
            user_id,
            reflection_type_id,
            reflection_title,
            reflection_start_date,
            reflection_end_date,
            created_at,
            reflection_type_master!inner(
              reflection_type_name
            )
          ''')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      // KindnessReflectionオブジェクトに変換
      return reflectionsResponse.map<KindnessReflection>((data) {
        final reflectionTypeName =
            data['reflection_type_master']['reflection_type_name'] as String?;
        return KindnessReflection.fromMap(
          data,
          reflectionTypeName: reflectionTypeName,
        );
      }).toList();
    } catch (e) {
      // エラーが発生した場合は空のリストを返す
      print('Reflections取得エラー: $e');
      return [];
    }
  }

  /// 特定のKindnessReflectionを取得
  Future<KindnessReflection?> fetchKindnessReflectionById(int id) async {
    try {
      final userId = _currentUserId;
      if (userId == null) {
        return null;
      }

      final response =
          await _supabase
              .from('kindness_reflections')
              .select('''
            id,
            user_id,
            reflection_type_id,
            reflection_title,
            reflection_start_date,
            reflection_end_date,
            created_at,
            reflection_type_master!inner(
              reflection_type_name
            )
          ''')
              .eq('id', id)
              .eq('user_id', userId)
              .single();

      final reflectionTypeName =
          response['reflection_type_master']['reflection_type_name'] as String?;
      return KindnessReflection.fromMap(
        response,
        reflectionTypeName: reflectionTypeName,
      );
    } catch (e) {
      print('Reflection取得エラー: $e');
      return null;
    }
  }

  /// Reflection期間内のKindnessRecordを取得してSummaryDataを生成
  Future<ReflectionSummaryData> getReflectionSummaryData(
    KindnessReflection reflection,
  ) async {
    try {
      final userId = _currentUserId;
      if (userId == null ||
          reflection.reflectionStartDate == null ||
          reflection.reflectionEndDate == null) {
        return ReflectionSummaryData(
          title: reflection.reflectionTitle ?? '',
          entriesCount: 0,
          daysCount: 0,
          peopleCount: 0,
          records: [],
        );
      }

      // 指定期間内のKindnessRecordを取得（kindness_giversとJOIN）
      final recordsResponse = await _supabase
          .from('kindness_records')
          .select('''
            id,
            user_id,
            giver_id,
            content,
            created_at,
            updated_at,
            kindness_givers!inner(
              giver_name
            )
          ''')
          .eq('user_id', userId)
          .gte('created_at', reflection.reflectionStartDate!.toIso8601String())
          .lte(
            'created_at',
            reflection.reflectionEndDate!
                .add(const Duration(days: 1))
                .toIso8601String(),
          )
          .order('created_at', ascending: false);

      // KindnessRecordオブジェクトに変換
      final records =
          recordsResponse.map<KindnessRecord>((data) {
            return KindnessRecord(
              id: data['id'] as int,
              userId: data['user_id'] as String,
              giverId: data['giver_id'] as int,
              content: data['content'] as String?,
              createdAt: DateTime.parse(data['created_at'].toString()),
              updatedAt:
                  data['updated_at'] != null
                      ? DateTime.parse(data['updated_at'].toString())
                      : null,
              giverName: data['kindness_givers']['giver_name'] as String,
              giverAvatarUrl: null, // 現在はnull
            );
          }).toList();

      // 統計を自動計算
      final statistics = SummaryStatistics.fromRecords(records);

      return ReflectionSummaryData(
        title: reflection.reflectionTitle ?? '',
        entriesCount: statistics.entriesCount,
        daysCount: statistics.daysCount,
        peopleCount: statistics.peopleCount,
        records: records,
      );
    } catch (e) {
      print('ReflectionSummary取得エラー: $e');
      return ReflectionSummaryData(
        title: reflection.reflectionTitle ?? '',
        entriesCount: 0,
        daysCount: 0,
        peopleCount: 0,
        records: [],
      );
    }
  }

  /// reflection_type_masterテーブルからデータを取得
  Future<List<Map<String, dynamic>>> fetchReflectionTypes() async {
    try {
      final response = await _supabase
          .from('reflection_type_master')
          .select()
          .order('id');
      return response;
    } catch (e) {
      print('ReflectionTypeマスター取得エラー: $e');
      return [];
    }
  }
}
