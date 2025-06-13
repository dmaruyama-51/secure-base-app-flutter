// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/auth_model.dart';

/// 認証画面用のViewModel
class AuthViewModel extends ChangeNotifier {
  // 状態プロパティ
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _shouldNavigate = false;
  String? _navigationPath;

  // ゲッター
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get shouldNavigate => _shouldNavigate;
  String? get navigationPath => _navigationPath;

  /// ログイン処理
  Future<void> signIn({
    required String email,
    required String password,
    String? redirectPath,
  }) async {
    _setLoading(true);
    _clearMessages();

    try {
      final result = await AuthModel.signIn(
        email: email,
        password: password,
        redirectPath: redirectPath,
      );

      if (result.isSuccess) {
        _successMessage = 'ログインしました';
        _shouldNavigate = true;
        _navigationPath = result.redirectPath;
      } else {
        _errorMessage = result.errorMessage;
      }
    } catch (e) {
      _errorMessage = 'ログインに失敗しました';
    } finally {
      _setLoading(false);
    }
  }

  /// サインアップ処理
  Future<void> signUp({required String email, required String password}) async {
    _setLoading(true);
    _clearMessages();

    try {
      final result = await AuthModel.signUp(email: email, password: password);

      if (result.isSuccess) {
        _successMessage = 'アカウントを作成しました';
        _shouldNavigate = true;
        _navigationPath = result.redirectPath;
      } else {
        _errorMessage = result.errorMessage;
      }
    } catch (e) {
      _errorMessage = 'アカウントの作成に失敗しました';
    } finally {
      _setLoading(false);
    }
  }

  /// ローディング状態を設定
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  /// メッセージをクリア
  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    _shouldNavigate = false;
    _navigationPath = null;
  }

  /// 画面遷移後のクリーンアップ
  void clearNavigation() {
    _shouldNavigate = false;
    _navigationPath = null;
    _successMessage = null;
    _errorMessage = null;
    notifyListeners();
  }
}
