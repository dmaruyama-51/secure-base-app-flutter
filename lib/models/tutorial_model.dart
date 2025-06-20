// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'kindness_giver.dart';
import 'kindness_record.dart';
import 'repositories/kindness_giver_repository.dart';
import 'repositories/kindness_record_repository.dart';
import 'repositories/tutorial_repository.dart';

/// チュートリアル機能のビジネスロジックを担当するクラス
class Tutorial {
  // 遅延時間の定数
  static const int _reflectionSaveDelayMs = 500;

  /// チュートリアルでメンバーを作成する
  static Future<KindnessGiver> createTutorialKindnessGiver({
    required String kindnessGiverName,
    required String selectedGender,
    required String selectedRelation,
    KindnessGiverRepository? repository,
  }) async {
    final repo = repository ?? KindnessGiverRepository();

    // 現在のユーザーを取得
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('ユーザーが認証されていません');
    }

    try {
      // マスターデータからIDを取得
      final genderId = await repo.getGenderIdByName(selectedGender);
      final relationshipId = await repo.getRelationshipIdByName(
        selectedRelation,
      );

      if (genderId == null) {
        throw Exception('選択された性別が見つかりません: $selectedGender');
      }

      if (relationshipId == null) {
        throw Exception('選択された関係性が見つかりません: $selectedRelation');
      }

      // KindnessGiver作成
      final kindnessGiver = KindnessGiver.create(
        userId: user.id,
        giverName: kindnessGiverName.trim(),
        relationshipId: relationshipId,
        genderId: genderId,
      );

      return await repo.createKindnessGiver(kindnessGiver);
    } catch (e) {
      throw Exception('メンバーの登録に失敗しました: $e');
    }
  }

  /// チュートリアルでやさしさ記録を作成する
  static Future<void> recordTutorialKindness({
    required String kindnessContent,
    required String selectedGender,
    required String selectedRelation,
    KindnessGiverRepository? kindnessGiverRepository,
    KindnessRecordRepository? kindnessRecordRepository,
  }) async {
    if (kindnessContent.trim().isEmpty) {
      return; // 空の場合はスキップ
    }

    final giverRepo = kindnessGiverRepository ?? KindnessGiverRepository();
    final recordRepo = kindnessRecordRepository ?? KindnessRecordRepository();

    try {
      // 現在のユーザーを取得
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      // 作成されたKindnessGiverを取得
      final kindnessGivers = await giverRepo.fetchKindnessGivers();
      if (kindnessGivers.isEmpty) {
        throw Exception('メンバーが見つかりません');
      }

      final kindnessGiver = kindnessGivers.first;

      // KindnessRecord作成
      final now = DateTime.now();
      final kindnessRecord = KindnessRecord(
        userId: user.id,
        giverId: kindnessGiver.id,
        content: kindnessContent,
        createdAt: now,
        updatedAt: now,
        giverName: kindnessGiver.giverName,
        giverAvatarUrl: kindnessGiver.avatarUrl,
        giverCategory: kindnessGiver.relationshipName ?? selectedRelation,
        giverGender: kindnessGiver.genderName ?? selectedGender,
      );

      await recordRepo.saveKindnessRecord(kindnessRecord);
    } catch (e) {
      throw Exception('優しさの記録に失敗しました: $e');
    }
  }

  /// リフレクション設定を完了する（設定保存 + チュートリアル完了マーク）
  static Future<void> completeReflectionSettings({
    required String selectedReflectionFrequency,
    TutorialRepository? repository,
  }) async {
    final repo = repository ?? TutorialRepository();

    try {
      // 現在のユーザーを取得
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      // 保存の遅延（UI効果）
      await Future.delayed(Duration(milliseconds: _reflectionSaveDelayMs));

      // 1. リフレクション頻度をDBに保存
      await repo.saveReflectionFrequency(selectedReflectionFrequency);

      // 2. チュートリアル完了をマーク
      await repo.markTutorialCompleted();
    } catch (e) {
      throw Exception('リフレクション設定の完了に失敗しました: $e');
    }
  }

  /// リフレクション設定を保存する
  static Future<void> saveReflectionSettings({
    required String selectedReflectionFrequency,
    TutorialRepository? repository,
  }) async {
    final repo = repository ?? TutorialRepository();

    try {
      // 現在のユーザーを取得
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      // リフレクション頻度をDBに保存
      await repo.saveReflectionFrequency(selectedReflectionFrequency);
    } catch (e) {
      throw Exception('リフレクション設定の保存に失敗しました: $e');
    }
  }

  /// チュートリアル完了処理
  static Future<void> completeTutorial({
    required String kindnessGiverName,
    required String selectedGender,
    required String selectedRelation,
    TutorialRepository? repository,
  }) async {
    final repo = repository ?? TutorialRepository();

    try {
      // KindnessGiver作成
      await createTutorialKindnessGiver(
        kindnessGiverName: kindnessGiverName,
        selectedGender: selectedGender,
        selectedRelation: selectedRelation,
      );

      // チュートリアル完了マーク
      await repo.markTutorialCompleted();
    } catch (e) {
      throw Exception('チュートリアルの完了処理に失敗しました: $e');
    }
  }

  /// 頻度の説明文を取得
  static String getFrequencyDescription(String frequency) {
    switch (frequency) {
      case '週に1回':
        return 'こまめに記録する方におすすめ';
      case '2週に1回':
        return 'バランスのよい推奨設定';
      case '月に1回':
        return '記録する頻度が少ない方におすすめ';
      default:
        return '';
    }
  }
}
