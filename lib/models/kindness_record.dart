import 'package:supabase_flutter/supabase_flutter.dart';
import 'repositories/kindness_record_repository.dart';
import 'repositories/kindness_giver_repository.dart';
import 'kindness_giver.dart';

/// バリデーションエラー用の例外クラス（KindnessRecord用）
class KindnessRecordValidationException implements Exception {
  final String message;

  KindnessRecordValidationException(this.message);

  @override
  String toString() => message;
}

class KindnessRecord {
  final int? id;
  final String userId;
  final int? giverId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String giverName; // kindness_giversテーブルから取得する情報
  final String? giverAvatarUrl; // kindness_giversテーブルから取得する情報
  final String giverCategory; // kindness_giversテーブルから取得する情報（必須）
  final String giverGender; // kindness_giversテーブルから取得する情報（必須）

  KindnessRecord({
    this.id,
    required this.userId,
    required this.giverId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.giverName,
    this.giverAvatarUrl,
    required this.giverCategory,
    required this.giverGender,
  });

  // ===== ビジネスロジック（静的メソッド） =====

  /// やさしさ記録の初期化データを取得する
  static Future<List<KindnessGiver>> fetchKindnessGiversForRecordAdd({
    KindnessGiverRepository? repository,
  }) async {
    final repo = repository ?? KindnessGiverRepository();
    try {
      final kindnessGivers = await repo.fetchKindnessGivers();
      if (kindnessGivers.isEmpty) {
        throw Exception('記録できるメンバーがいません。まずメンバーを追加してください。');
      }
      return kindnessGivers;
    } catch (e) {
      throw Exception('メンバー一覧の取得に失敗しました: $e');
    }
  }

  /// 新しいやさしさ記録を作成する
  static Future<KindnessRecord> createKindnessRecord({
    required String content,
    required KindnessGiver? selectedKindnessGiver,
    KindnessRecordRepository? repository,
  }) async {
    final repo = repository ?? KindnessRecordRepository();

    // バリデーション
    _validateKindnessRecordInput(content, selectedKindnessGiver);

    // 現在のユーザーを取得
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw KindnessRecordValidationException('ユーザーが認証されていません');
    }

    // レコード作成
    final now = DateTime.now();
    final kindnessRecord = KindnessRecord(
      userId: user.id,
      giverId: selectedKindnessGiver!.id,
      content: content.trim(),
      createdAt: now,
      updatedAt: now,
      giverName: selectedKindnessGiver.giverName,
      giverAvatarUrl: selectedKindnessGiver.avatarUrl,
      giverCategory: selectedKindnessGiver.relationshipName ?? '',
      giverGender: selectedKindnessGiver.genderName ?? '',
    );

    try {
      await repo.saveKindnessRecord(kindnessRecord);
      return kindnessRecord;
    } catch (e) {
      throw Exception('やさしさ記録の保存に失敗しました: $e');
    }
  }

  /// やさしさ記録を更新する
  static Future<KindnessRecord> updateKindnessRecord({
    required KindnessRecord originalRecord,
    required String content,
    required KindnessGiver? selectedKindnessGiver,
    KindnessRecordRepository? repository,
  }) async {
    final repo = repository ?? KindnessRecordRepository();

    // バリデーション
    _validateKindnessRecordInput(content, selectedKindnessGiver);

    if (originalRecord.id == null) {
      throw KindnessRecordValidationException('編集対象のレコードが見つかりません');
    }

    // 現在のユーザーを取得
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw KindnessRecordValidationException('ユーザーが認証されていません');
    }

    // レコード更新
    final updatedRecord = KindnessRecord(
      id: originalRecord.id,
      userId: user.id,
      giverId: selectedKindnessGiver!.id,
      content: content.trim(),
      createdAt: originalRecord.createdAt,
      updatedAt: DateTime.now(),
      giverName: selectedKindnessGiver.giverName,
      giverAvatarUrl: selectedKindnessGiver.avatarUrl,
      giverCategory: selectedKindnessGiver.relationshipName ?? '',
      giverGender: selectedKindnessGiver.genderName ?? '',
    );

    try {
      await repo.updateKindnessRecord(updatedRecord);
      return updatedRecord;
    } catch (e) {
      throw Exception('やさしさ記録の更新に失敗しました: $e');
    }
  }

  /// やさしさ記録一覧を取得する
  static Future<List<KindnessRecord>> fetchKindnessRecords({
    KindnessRecordRepository? repository,
    int limit = 50,
    int offset = 0,
  }) async {
    final repo = repository ?? KindnessRecordRepository();
    try {
      return await repo.fetchKindnessRecords(limit: limit, offset: offset);
    } catch (e) {
      throw Exception('やさしさ記録の取得に失敗しました: $e');
    }
  }

  /// 編集用の初期化データを取得する
  static Future<
    ({List<KindnessGiver> kindnessGivers, KindnessGiver? selectedGiver})
  >
  fetchKindnessGiversForRecordEdit({
    required KindnessRecord originalRecord,
    KindnessGiverRepository? repository,
  }) async {
    final repo = repository ?? KindnessGiverRepository();
    try {
      final kindnessGivers = await repo.fetchKindnessGivers();

      // 元のレコードに対応するKindnessGiverを選択
      KindnessGiver? selectedGiver;
      if (kindnessGivers.isNotEmpty) {
        selectedGiver =
            kindnessGivers
                .where((giver) => giver.id == originalRecord.giverId)
                .firstOrNull ??
            kindnessGivers.first;
      }

      return (kindnessGivers: kindnessGivers, selectedGiver: selectedGiver);
    } catch (e) {
      throw Exception('メンバー一覧の取得に失敗しました: $e');
    }
  }

  /// やさしさ記録を削除する
  static Future<void> deleteKindnessRecord({
    required int recordId,
    KindnessRecordRepository? repository,
  }) async {
    final repo = repository ?? KindnessRecordRepository();

    try {
      final success = await repo.deleteKindnessRecord(recordId);
      if (!success) {
        throw Exception('やさしさ記録の削除に失敗しました');
      }
    } catch (e) {
      throw Exception('やさしさ記録の削除に失敗しました: $e');
    }
  }

  /// やさしさ記録の入力バリデーション
  static void _validateKindnessRecordInput(
    String content,
    KindnessGiver? selectedKindnessGiver,
  ) {
    if (content.trim().isEmpty) {
      throw KindnessRecordValidationException('やさしさの内容を入力してください');
    }
    if (selectedKindnessGiver == null) {
      throw KindnessRecordValidationException('メンバーを選択してください');
    }
  }
}
