import 'package:flutter/material.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../models/kindness_giver.dart';

class KindnessGiverAddViewModel extends ChangeNotifier {
  // リポジトリの注入
  final KindnessGiverRepository _repository;

  // 状態管理
  String selectedGender = '女性';
  String selectedRelation = '家族';
  String? errorMessage;
  String? successMessage;
  bool isSaving = false;
  bool shouldNavigateBack = false;

  // ID管理用の変数を追加
  int genderId = 1; // 女性のデフォルトID
  int relationshipId = 1; // 家族のデフォルトID

  // テキスト入力の管理
  final TextEditingController nameController = TextEditingController();

  // マスターデータ保持用の変数
  List<Map<String, dynamic>> relationships = [];
  List<Map<String, dynamic>> genders = [];

  // コンストラクタでリポジトリの注入と初期値の設定
  KindnessGiverAddViewModel({KindnessGiverRepository? repository})
    : _repository = repository ?? KindnessGiverRepository() {
    _loadMasterData(); // 初期化時にマスターデータ読み込み
  }

  // マスターデータ読み込みメソッド
  Future<void> _loadMasterData() async {
    relationships = await _repository.fetchRelationships();
    genders = await _repository.fetchGenders();
    notifyListeners();
  }

  // 性別選択
  void selectGender(String gender) {
    selectedGender = gender;
    // IDを取得
    final selectedGenderData = genders.firstWhere(
      (g) => g['name'] == gender,
      orElse: () => {'id': 1},
    );
    genderId = selectedGenderData['id'];
    notifyListeners();
  }

  // 関係性選択
  void selectRelation(String relation) {
    selectedRelation = relation;
    // IDを取得
    final selectedRelationData = relationships.firstWhere(
      (r) => r['name'] == relation,
      orElse: () => {'id': 1},
    );
    relationshipId = selectedRelationData['id'];
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
