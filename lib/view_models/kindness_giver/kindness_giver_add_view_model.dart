import 'package:flutter/material.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../models/kindness_giver.dart';
import '../../utils/constants.dart';
import 'kindness_giver_base_view_model.dart';

class KindnessGiverAddViewModel extends KindnessGiverBaseViewModel {
  // コンストラクタ
  KindnessGiverAddViewModel()
    : super(
        repository: KindnessGiverRepository(),
        selectedGender: '女性',
        selectedRelation: '家族',
        relationshipId: 1,
        genderId: 1,
        nameController: TextEditingController(),
      );

  // メンバー保存処理
  @override
  Future<void> createKindnessGiver() async {
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

      // リポジトリを通じて新規作成
      final createdGiver = await repository.createKindnessGiver(kindnessGiver);

      // IDが付与されていれば成功
      if (createdGiver) {
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

  @override
  Future<void> updateKindnessGiver() async {
    // この ViewModel では更新処理は行わない
    throw UnimplementedError(
      'Update operation is not supported in AddViewModel.',
    );
  }

  @override
  Future<void> deleteKindnessGiver(int kindnessGiverId) async {
    // この ViewModel では削除処理は行わない
    throw UnimplementedError(
      'Delete operation is not supported in AddViewModel.',
    );
  }
}
