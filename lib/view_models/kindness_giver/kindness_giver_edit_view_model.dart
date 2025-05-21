import 'package:flutter/material.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../models/kindness_giver.dart';
import '../../utils/constants.dart';
import 'kindness_giver_base_view_model.dart';

class KindnessGiverEditViewModel extends KindnessGiverBaseViewModel {
  // 編集対象のメンバー
  final KindnessGiver originalKindnessGiver;

  KindnessGiverEditViewModel({
    required KindnessGiver kindnessGiver,
    KindnessGiverRepository? repository,
  }) : originalKindnessGiver = kindnessGiver,
       super(
         repository: repository ?? KindnessGiverRepository(),
         selectedGender: kindnessGiver.gender,
         selectedRelation: kindnessGiver.relationship,
         relationshipId: kindnessGiver.relationshipId,
         genderId: kindnessGiver.genderId,
         nameController: TextEditingController(text: kindnessGiver.name),
       );

  @override
  Future<void> saveKindnessGiver() async {
    return updateKindnessGiver();
  }

  // メンバー更新処理
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

      // リポジトリを通じて保存
      final result = await repository.saveKindnessGiver(updatedKindnessGiver);

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
}
