// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/kindness_giver.dart';
import '../../repositories/kindness_giver_repository.dart';

/// メンバー編集のViewModel
class KindnessGiverEditViewModel extends ChangeNotifier {
  final KindnessGiverRepository _repository;

  // 状態プロパティ
  KindnessGiver? _originalKindnessGiver;
  String _name = '';
  String _selectedGender = '女性';
  String _selectedRelation = '家族';
  int? _selectedGenderId;
  int? _selectedRelationshipId;
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  bool _shouldNavigateBack = false;

  KindnessGiverEditViewModel({required KindnessGiver originalKindnessGiver})
    : _repository = KindnessGiverRepository(),
      _originalKindnessGiver = originalKindnessGiver,
      _name = originalKindnessGiver.giverName,
      _selectedGender = originalKindnessGiver.genderName ?? '女性',
      _selectedRelation = originalKindnessGiver.relationshipName ?? '家族';

  // ゲッター
  KindnessGiver? get originalKindnessGiver => _originalKindnessGiver;
  String get name => _name;
  String get selectedGender => _selectedGender;
  String get selectedRelation => _selectedRelation;
  int? get selectedGenderId => _selectedGenderId;
  int? get selectedRelationshipId => _selectedRelationshipId;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get shouldNavigateBack => _shouldNavigateBack;

  /// 名前を更新
  void updateName(String name) {
    _name = name;
    notifyListeners();
  }

  /// 性別選択時の処理
  Future<void> selectGender(String gender) async {
    final genderId = await _repository.getGenderIdByName(gender);
    _selectedGender = gender;
    _selectedGenderId = genderId;
    notifyListeners();
  }

  /// 関係性選択時の処理
  Future<void> selectRelation(String relation) async {
    final relationshipId = await _repository.getRelationshipIdByName(relation);
    _selectedRelation = relation;
    _selectedRelationshipId = relationshipId;
    notifyListeners();
  }

  /// バリデーション
  bool _validateInput() {
    if (_name.trim().isEmpty) {
      _errorMessage = '名前を入力してください';
      notifyListeners();
      return false;
    }

    if (_selectedRelation.isEmpty) {
      _errorMessage = '関係性を選択してください';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    notifyListeners();
    return true;
  }

  /// やさしさをくれる人更新処理
  Future<void> updateKindnessGiver() async {
    if (!_validateInput()) return;

    // IDが取得できていない場合は再取得
    if (_selectedGenderId == null || _selectedRelationshipId == null) {
      await _ensureIdsAreLoaded();
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedKindnessGiver = _originalKindnessGiver!.copyWith(
        giverName: _name.trim(),
        genderId: _selectedGenderId!,
        relationshipId: _selectedRelationshipId!,
      );

      await _repository.updateKindnessGiver(updatedKindnessGiver);
      _isSaving = false;
      _successMessage = 'メンバーが更新されました';
      _shouldNavigateBack = true;
      notifyListeners();
    } catch (e) {
      _isSaving = false;
      _errorMessage = 'メンバーの更新に失敗しました: $e';
      notifyListeners();
    }
  }

  /// IDが読み込まれていることを確認
  Future<void> _ensureIdsAreLoaded() async {
    if (_selectedGenderId == null) {
      final genderId = await _repository.getGenderIdByName(_selectedGender);
      _selectedGenderId = genderId;
    }
    if (_selectedRelationshipId == null) {
      final relationshipId = await _repository.getRelationshipIdByName(
        _selectedRelation,
      );
      _selectedRelationshipId = relationshipId;
    }
  }

  /// メッセージをクリア
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _shouldNavigateBack = false;
    notifyListeners();
  }

  Future<void> initializeWithKindnessGiver(
    KindnessGiver originalKindnessGiver,
  ) async {
    _originalKindnessGiver = originalKindnessGiver;
    _name = originalKindnessGiver.giverName;
    _selectedGender = originalKindnessGiver.genderName ?? '女性';
    _selectedRelation = originalKindnessGiver.relationshipName ?? '家族';
    notifyListeners();
  }
}
