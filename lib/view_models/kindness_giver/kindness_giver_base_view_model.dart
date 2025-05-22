import 'package:flutter/material.dart';
import '../../repositories/kindness_giver_repository.dart';

// メンバー追加と編集の共通ビューモデル
abstract class KindnessGiverBaseViewModel extends ChangeNotifier {
  // リポジトリの注入
  final KindnessGiverRepository repository;

  // 状態管理
  String selectedGender;
  String selectedRelation;
  String? errorMessage;
  String? successMessage;
  bool isSaving = false;
  bool shouldNavigateBack = false;

  // テキスト入力の管理
  final TextEditingController nameController;

  // マスターデータ保持用の変数
  List<Map<String, dynamic>> relationships = [];
  List<Map<String, dynamic>> genders = [];

  // IDを保持する変数
  int relationshipId;
  int genderId;

  // コンストラクタ
  KindnessGiverBaseViewModel({
    required this.repository,
    required this.selectedGender,
    required this.selectedRelation,
    required this.relationshipId,
    required this.genderId,
    required this.nameController,
  }) {
    _loadMasterData();
  }

  // マスターデータ読み込みメソッド
  Future<void> _loadMasterData() async {
    relationships = await repository.fetchRelationships();
    genders = await repository.fetchGenders();
    notifyListeners();
  }

  // 性別選択
  void selectGender(String gender) {
    selectedGender = gender;
    // IDを取得
    final selectedGenderData = genders.firstWhere(
      (g) => g['name'] == gender,
      orElse: () => {'id': genderId},
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
      orElse: () => {'id': relationshipId},
    );
    relationshipId = selectedRelationData['id'];
    notifyListeners();
  }

  // バリデーション
  bool validateInput() {
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

  // メンバー追加
  Future<void> createKindnessGiver();

  /// メンバー更新
  Future<void> updateKindnessGiver();

  /// メンバー削除
  Future<void> deleteKindnessGiver(int kindnessGiverId);

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
