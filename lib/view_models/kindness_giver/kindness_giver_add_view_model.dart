// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/kindness_giver.dart';

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

  // TextEditingController同期用
  bool _isTextControllerSyncing = false;

  // ゲッター
  String get name => _name;
  String get selectedGender => _selectedGender;
  String get selectedRelation => _selectedRelation;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get shouldNavigateBack => _shouldNavigateBack;
  bool get isTextControllerSyncing => _isTextControllerSyncing;

  /// 名前を更新（TextEditingControllerからの呼び出し）
  void updateName(String name) {
    if (_name != name) {
      _name = name;
      notifyListeners();
    }
  }

  /// 名前を設定（プログラムからの設定）
  void setName(String name) {
    if (_name != name) {
      _isTextControllerSyncing = true;
      _name = name;
      notifyListeners();
      Future.microtask(() {
        _isTextControllerSyncing = false;
        notifyListeners();
      });
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
