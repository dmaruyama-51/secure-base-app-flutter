import 'package:flutter/material.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../models/kindness_giver.dart';
import '../../utils/constants.dart';
import 'kindness_giver_base_view_model.dart';

class KindnessGiverEditViewModel extends KindnessGiverBaseViewModel {
  // リポジトリのインスタンス化
  final KindnessGiverRepository _repository = KindnessGiverRepository();

  // 編集対象のメンバー
  final KindnessGiver originalKindnessGiver;

  // テキスト入力の管理
  final TextEditingController nameController;

  // コンストラクタでモデルのみを受け取る
  KindnessGiverEditViewModel({required KindnessGiver kindnessGiver})

  // メンバー更新処理
  @override
  Future<void> updateKindnessGiver() async {
    if (!validateInput()) {
      return;
    }

    try {
      isSaving = true;
      notifyListeners();

      // 更新用のKindnessGiverモデルの作成
      final updatedKindnessGiver = KindnessGiver(
        id: originalKindnessGiver.id,
        name: nameController.text.trim(),
        gender: selectedGender,
        relationship: selectedRelation,
        avatarUrl: originalKindnessGiver.avatarUrl,
        userId: originalKindnessGiver.userId,
        relationshipId: relationshipId,
        genderId: genderId,
      );

      // 更新処理
      final result = await _repository.updateKindnessGiver(updatedKindnessGiver);

      if (result) {
        successMessage = 'メンバー情報を更新しました';
        shouldNavigateBack = true;

        // 保存に成功したら、リストを更新するためのイベントを発火
        kindnessGiverListUpdateNotifier.notifyListeners();
      } else {
        errorMessage = '更新に失敗しました';
      }
    } catch (e) {
      errorMessage = 'エラーが発生しました: ${e.toString()}';
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  @override
  Future<void> createKindnessGiver() async {
    // この ViewModel では新規作成処理は行わない
    throw UnimplementedError(
      'Create operation is not supported in EditViewModel.',
    );
  }

  @override
  Future<void> deleteKindnessGiver(int kindnessGiverId) async {
    throw UnimplementedError(
      'Delete operation is not implemented yet in EditViewModel.',
    );
  }
}
