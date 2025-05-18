import 'package:flutter/material.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../models/kindness_giver.dart';

class KindnessGiverEditViewModel extends ChangeNotifier {
  // リポジトリの注入
  final KindnessGiverRepository _repository;

  // 編集対象のメンバー
  final KindnessGiver originalKindnessGiver;

  // 状態管理
  String selectedGender;
  String selectedRelation;
  String? errorMessage;
  String? successMessage;
  bool isSaving = false;
  bool shouldNavigateBack = false;

  // テキスト入力の管理
  final TextEditingController nameController;

  // コンストラクタでリポジトリの注入と初期値の設定
  KindnessGiverEditViewModel({
    required KindnessGiver kindnessGiver,
    KindnessGiverRepository? repository,
  }) : _repository = repository ?? KindnessGiverRepository(),
       originalKindnessGiver = kindnessGiver,
       selectedGender = kindnessGiver.gender,
       selectedRelation = kindnessGiver.category,
       nameController = TextEditingController(text: kindnessGiver.name);

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

  // メンバー更新処理
  Future<void> updateKindnessGiver() async {
    if (!_validateInput()) {
      return;
    }

    try {
      isSaving = true;
      notifyListeners();

      // 更新用のKindnessGiverモデルの作成
      final updatedKindnessGiver = KindnessGiver(
        name: nameController.text.trim(),
        gender: selectedGender,
        category: selectedRelation,
        avatarUrl: originalKindnessGiver.avatarUrl,
      );

      // リポジトリを通じて保存
      final result = await _repository.saveKindnessGiver(updatedKindnessGiver);

      if (result) {
        successMessage = 'メンバー情報を更新しました';
        shouldNavigateBack = true;
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

  // エラーメッセージと成功メッセージをクリアする
  void clearMessages() {
    errorMessage = null;
    successMessage = null;
    shouldNavigateBack = false;
    notifyListeners();
  }

  // 性別に基づいてアイコンを返す
  IconData getGenderIcon(String gender) {
    switch (gender) {
      case '女性':
        return Icons.female;
      case '男性':
        return Icons.male;
      case 'ペット':
        return Icons.pets;
      default:
        return Icons.person;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
