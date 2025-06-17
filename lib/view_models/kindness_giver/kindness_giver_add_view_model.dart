// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/kindness_giver.dart';

/// バリデーションエラー用の例外クラス（KindnessGiver用）
class KindnessGiverValidationException implements Exception {
  final String message;

  KindnessGiverValidationException(this.message);

  @override
  String toString() => message;
}

/// メンバー追加のViewModel（Provider対応版）
class KindnessGiverAddViewModel extends ChangeNotifier {
  // 状態プロパティ
  String _name = '';
  String _selectedGender = '女性';
  String _selectedRelation = '家族';
  bool _isSaving = false;
  String? _errorMessage;
  String? _successMessage;
  bool _shouldNavigateBack = false;

  // ゲッター
  String get name => _name;
  String get selectedGender => _selectedGender;
  String get selectedRelation => _selectedRelation;
  bool get isSaving => _isSaving;
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

  /// 名前を更新（TextEditingControllerからの呼び出し）
  void updateName(String name) {
    if (_name != name) {
      _name = name;
      notifyListeners();
    }
  }

  /// 性別を選択
  void selectGender(String gender) {
    _selectedGender = gender;
    notifyListeners();
  }

  /// 関係性を選択
  void selectRelation(String relation) {
    _selectedRelation = relation;
    notifyListeners();
  }

  /// やさしさをくれる人を保存
  Future<void> saveKindnessGiver() async {
    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // バリデーション
      _validateBasicInput();

      await KindnessGiver.createKindnessGiver(
        giverName: _name,
        genderName: _selectedGender,
        relationshipName: _selectedRelation,
      );

      _isSaving = false;
      _successMessage = 'メンバーを保存しました';
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
}
