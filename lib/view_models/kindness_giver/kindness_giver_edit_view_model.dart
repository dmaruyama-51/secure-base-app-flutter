// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/kindness_giver_model.dart';

/// バリデーションエラー用の例外クラス（KindnessGiver用）
class KindnessGiverValidationException implements Exception {
  final String message;

  KindnessGiverValidationException(this.message);

  @override
  String toString() => message;
}

/// メンバー編集のViewModel
class KindnessGiverEditViewModel extends ChangeNotifier {
  // 状態プロパティ
  KindnessGiver? _originalKindnessGiver;
  String _name = '';
  String _selectedGender = '女性';
  String _selectedRelation = '家族';
  bool _isSaving = false;
  bool _isDeleting = false;
  String? _errorMessage;
  String? _successMessage;
  bool _shouldNavigateBack = false;

  KindnessGiverEditViewModel({required KindnessGiver originalKindnessGiver})
    : _originalKindnessGiver = originalKindnessGiver,
      _name = originalKindnessGiver.giverName,
      _selectedGender = originalKindnessGiver.genderName ?? '女性',
      _selectedRelation = originalKindnessGiver.relationshipName ?? '家族';

  // ゲッター
  KindnessGiver? get originalKindnessGiver => _originalKindnessGiver;
  String get name => _name;
  String get selectedGender => _selectedGender;
  String get selectedRelation => _selectedRelation;
  bool get isSaving => _isSaving;
  bool get isDeleting => _isDeleting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get shouldNavigateBack => _shouldNavigateBack;

  /// 基本的な入力値のバリデーション
  void _validateBasicInput() {
    if (_name.trim().isEmpty) {
      throw KindnessGiverValidationException('名前を入力してください');
    }
    if (_selectedGender.isEmpty) {
      throw KindnessGiverValidationException('性別を選択してください');
    }
    if (_selectedRelation.isEmpty) {
      throw KindnessGiverValidationException('関係性を選択してください');
    }
  }

  /// 名前を更新
  void updateName(String name) {
    _name = name;
    notifyListeners();
  }

  /// 性別選択時の処理
  void selectGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  /// 関係性選択時の処理
  void selectRelation(String relation) {
    _selectedRelation = relation;
    notifyListeners();
  }

  /// やさしさをくれる人更新処理
  Future<void> updateKindnessGiver() async {
    if (_originalKindnessGiver == null) return;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // バリデーション
      _validateBasicInput();

      await KindnessGiver.updateKindnessGiver(
        originalKindnessGiver: _originalKindnessGiver!,
        giverName: _name,
        genderName: _selectedGender,
        relationshipName: _selectedRelation,
      );

      _isSaving = false;
      _successMessage = 'メンバーが更新されました';
      _shouldNavigateBack = true;
      notifyListeners();
    } catch (e) {
      _isSaving = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// やさしさをくれる人削除処理
  Future<void> deleteKindnessGiver() async {
    if (_originalKindnessGiver == null) {
      _errorMessage = '削除対象のメンバーが見つかりません';
      notifyListeners();
      return;
    }

    if (_originalKindnessGiver!.id == null) {
      _errorMessage = '無効なメンバーIDです';
      notifyListeners();
      return;
    }

    _isDeleting = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await KindnessGiver.deleteKindnessGiver(_originalKindnessGiver!.id!);

      _isDeleting = false;
      _successMessage = 'メンバーを削除しました';
      _shouldNavigateBack = true;
      notifyListeners();
    } catch (e) {
      _isDeleting = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// メッセージをクリア
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _shouldNavigateBack = false;
    notifyListeners();
  }

  /// KindnessGiverで初期化
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
