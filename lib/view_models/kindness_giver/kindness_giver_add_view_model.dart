import 'package:flutter/material.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../models/kindness_giver.dart';
import '../../utils/constants.dart';
import 'kindness_giver_base_view_model.dart';

class KindnessGiverAddViewModel extends KindnessGiverBaseViewModel {
  KindnessGiverAddViewModel({KindnessGiverRepository? repository})
    : super(
        repository: repository ?? KindnessGiverRepository(),
        selectedGender: '女性',
        selectedRelation: '家族',
        relationshipId: 1,
        genderId: 1,
        nameController: TextEditingController(),
      );

  @override
  Future<void> saveKindnessGiver() async {
    if (!validateInput()) {
      return;
    }

    try {
      isSaving = true;
      notifyListeners();

      // KindnessGiverモデルの作成
      final kindnessGiver = KindnessGiver(
        name: nameController.text.trim(),
        gender: selectedGender,
        relationship: selectedRelation,
        userId: '', // リポジトリ内で自動設定
        relationshipId: relationshipId,
        genderId: genderId,
      );

      // リポジトリを通じて保存
      final result = await repository.saveKindnessGiver(kindnessGiver);

      if (result) {
        successMessage = 'メンバーを保存しました';
        shouldNavigateBack = true;

        // 保存に成功したら、リストを更新するためのイベントを発火
        kindnessGiverListUpdateNotifier.notifyListeners();
      } else {
        errorMessage = '保存に失敗しました';
      }
    } catch (e) {
      errorMessage = 'エラーが発生しました: ${e.toString()}';
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }
}
