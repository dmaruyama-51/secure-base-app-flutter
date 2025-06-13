import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
      // 設定データの読み込みなど
      await Future.delayed(Duration(seconds: 1)); // 模擬的な処理
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = '設定の読み込みに失敗しました';
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
      await Supabase.instance.client.auth.signOut();
      _isLoading = false;
      _successMessage = 'ログアウトしました';
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'ログアウトに失敗しました: ${e.toString()}';
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
