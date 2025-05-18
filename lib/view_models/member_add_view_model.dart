import 'package:flutter/material.dart';
import '../repositories/kindness_giver_repository.dart';
import '../models/kindness_giver.dart';

class KindnessGiverAddViewModel extends ChangeNotifier {
  // リポジトリの注入
  final KindnessGiverRepository _repository;

  // 状態管理
  String selectedGender = '女性';
  String selectedRelation = 'Friend';
  String? errorMessage;
  String? successMessage;
  bool isSaving = false;
  bool shouldNavigateBack = false;

  // テキスト入力の管理 (Viewからコントローラを移動)
  final TextEditingController nameController = TextEditingController();

  // コンストラクタでリポジトリの注入と初期値の設定
  KindnessGiverAddViewModel({KindnessGiverRepository? repository})
    : _repository = repository ?? KindnessGiverRepository();

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

    errorMessage = null;
    notifyListeners();
    return true;
  }

  // 優しさをくれる人保存処理
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
        category: selectedRelation,
      );

      // リポジトリを通じて保存
      final result = await _repository.saveKindnessGiver(kindnessGiver);

      if (result) {
        successMessage = 'メンバーを保存しました';
        shouldNavigateBack = true;
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
