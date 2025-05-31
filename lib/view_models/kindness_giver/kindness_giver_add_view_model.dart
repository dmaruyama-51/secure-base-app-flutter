import 'package:flutter/material.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../models/kindness_giver.dart';
import '../../utils/constants.dart';
import 'kindness_giver_base_view_model.dart';

class KindnessGiverAddViewModel extends ChangeNotifier {
  // リポジトリを内部でインスタンス化
  final KindnessGiverRepository _repository = KindnessGiverRepository();

  // 状態管理
  String selectedGender = '女性';
  String selectedRelation = '家族';
  String? errorMessage;
  String? successMessage;
  bool isSaving = false;
  bool shouldNavigateBack = false;

  // テキスト入力の管理 (Viewからコントローラを移動)
  final TextEditingController nameController = TextEditingController();

  // コンストラクタ
  KindnessGiverAddViewModel();

  // 性別選択
  void selectGender(String gender) {
    selectedGender = gender;
    notifyListeners();
  }

  // 関係性選択
  void selectRelation(String relation) {
    selectedRelation = relation;
    notifyListeners();
  }

  // バリデーション
  bool _validateInput() {
    if (nameController.text.trim().isEmpty) {
      errorMessage = '名前を入力してください';
      notifyListeners();
      return false;
    }

    if (selectedRelation.isEmpty) {
      errorMessage = '関係性を選択してください';
      notifyListeners();
      return false;
    }

    errorMessage = null;
    notifyListeners();
    return true;
  }

  // メンバー保存処理
  Future<void> saveKindnessGiver() async {
    if (!_validateInput()) {
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
      final createdGiver = await _repository.createKindnessGiver(kindnessGiver);

      // IDが付与されていれば成功
      if (createdGiver.id != null) {
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
