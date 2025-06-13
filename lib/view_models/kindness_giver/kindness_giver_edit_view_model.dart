// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/kindness_giver.dart';

/// メンバー編集のViewModel
class KindnessGiverEditViewModel extends ChangeNotifier {
  // 状態プロパティ
  KindnessGiver? _originalKindnessGiver;
  String _name = '';
  String _selectedGender = '女性';
  String _selectedRelation = '家族';
  bool _isSaving = false;
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
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get shouldNavigateBack => _shouldNavigateBack;

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
