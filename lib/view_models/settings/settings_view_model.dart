// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/settings_model.dart';

/// 設定のViewModel
class SettingsViewModel extends ChangeNotifier {
  // 状態プロパティ
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // ゲッター
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  /// 初期化
  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Settings.initialize();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// ログアウト処理
  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await Settings.signOut();
      _isLoading = false;
      _successMessage = 'ログアウトしました';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// メッセージをクリア
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }
}
