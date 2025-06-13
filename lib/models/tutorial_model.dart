import 'package:supabase_flutter/supabase_flutter.dart';
import 'repositories/kindness_giver_repository.dart';
import 'repositories/kindness_record_repository.dart';
import 'repositories/tutorial_repository.dart';
import 'kindness_giver.dart';
import 'kindness_record.dart';

/// チュートリアル関連のバリデーションエラー用の例外クラス
class TutorialValidationException implements Exception {
  final String message;

  TutorialValidationException(this.message);

  @override
  String toString() => message;
}

/// チュートリアル機能のビジネスロジックを担当するクラス
class Tutorial {
  // 遅延時間の定数
  static const int _reflectionSaveDelayMs = 500;

  /// チュートリアルでやさしさをくれる人を作成する
  static Future<KindnessGiver> createTutorialKindnessGiver({
    required String kindnessGiverName,
    required String selectedGender,
    required String selectedRelation,
    KindnessGiverRepository? repository,
  }) async {
    final repo = repository ?? KindnessGiverRepository();

    // バリデーション
    if (kindnessGiverName.trim().isEmpty) {
      throw TutorialValidationException('名前を入力してください');
    }

    // 現在のユーザーを取得
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw TutorialValidationException('ユーザーが認証されていません');
    }

    try {
      // マスターデータからIDを取得
      final genderId = await repo.getGenderIdByName(selectedGender);
      final relationshipId = await repo.getRelationshipIdByName(
        selectedRelation,
      );

      if (genderId == null) {
        throw TutorialValidationException('選択された性別が見つかりません: $selectedGender');
      }

      if (relationshipId == null) {
        throw TutorialValidationException(
          '選択された関係性が見つかりません: $selectedRelation',
        );
      }

      // KindnessGiver作成
      final kindnessGiver = KindnessGiver.create(
        userId: user.id,
        giverName: kindnessGiverName,
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
        throw TutorialValidationException('ユーザーが認証されていません');
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

  /// リフレクション設定を保存する
  static Future<void> saveReflectionSettings({
    required String selectedReflectionFrequency,
  }) async {
    try {
      // 現在のユーザーを取得
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw TutorialValidationException('ユーザーが認証されていません');
      }

      // 保存の遅延（UI効果）
      await Future.delayed(Duration(milliseconds: _reflectionSaveDelayMs));

      // 実際の保存処理はここに実装
      print('リフレクション頻度を保存しました: $selectedReflectionFrequency');
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
        return '毎週、受け取った優しさを振り返ります';
      case '2週に1回':
        return '2週間ごとに振り返りの時間をお届けします';
      case '月に1回':
        return '月末に1ヶ月分の優しさをまとめて振り返ります';
      default:
        return '';
    }
  }
}
