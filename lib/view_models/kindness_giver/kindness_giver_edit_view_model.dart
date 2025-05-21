import 'package:flutter/material.dart';
import '../../repositories/kindness_giver_repository.dart';
import '../../models/kindness_giver.dart';
import '../../utils/constants.dart';

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

  // マスターデータ保持用の変数を追加
  List<Map<String, dynamic>> relationships = [];
  List<Map<String, dynamic>> genders = [];

  // IDを保持する変数を追加
  int relationshipId;
  int genderId;

  // コンストラクタでリポジトリの注入と初期値の設定
  KindnessGiverEditViewModel({
    required KindnessGiver kindnessGiver,
    KindnessGiverRepository? repository,
  }) : _repository = repository ?? KindnessGiverRepository(),
       originalKindnessGiver = kindnessGiver,
       selectedGender = kindnessGiver.gender,
       selectedRelation = kindnessGiver.relationship,
       relationshipId = kindnessGiver.relationshipId,
       genderId = kindnessGiver.genderId,
       nameController = TextEditingController(text: kindnessGiver.name) {
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
      orElse: () => {'id': genderId}, // 元のIDをデフォルト値として使用
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
      orElse: () => {'id': relationshipId}, // 元のIDをデフォルト値として使用
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
        id: originalKindnessGiver.id,
        name: nameController.text.trim(),
        gender: selectedGender,
        relationship: selectedRelation,
        avatarUrl: originalKindnessGiver.avatarUrl,
        userId: originalKindnessGiver.userId,
        relationshipId: relationshipId, // 更新されたID
        genderId: genderId, // 更新されたID
      );

      // リポジトリを通じて保存
      final result = await _repository.saveKindnessGiver(updatedKindnessGiver);

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
