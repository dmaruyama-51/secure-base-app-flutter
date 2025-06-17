// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../models/auth_model.dart';

/// 認証バリデーションエラー用の例外クラス
class AuthValidationException implements Exception {
  final String message;

  AuthValidationException(this.message);

  @override
  String toString() => message;
}

/// 認証画面用のViewModel
class AuthViewModel extends ChangeNotifier {
  // 状態プロパティ
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  bool _shouldNavigate = false;
  String? _navigationPath;

  // フォームバリデーション用
  String? _emailError;
  String? _passwordError;

  // ゲッター
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get shouldNavigate => _shouldNavigate;
  String? get navigationPath => _navigationPath;
  String? get emailError => _emailError;
  String? get passwordError => _passwordError;

  /// ログイン用バリデーション
  void _validateSignInInput(String email, String password) {
    if (email.trim().isEmpty) {
      throw AuthValidationException('メールアドレスを入力してください');
    }
    if (password.trim().isEmpty) {
      throw AuthValidationException('パスワードを入力してください');
    }
  }

  /// サインアップ用バリデーション
  void _validateSignUpInput(String email, String password) {
    if (email.trim().isEmpty) {
      throw AuthValidationException('メールアドレスを入力してください');
    }
    if (password.trim().isEmpty) {
      throw AuthValidationException('パスワードを入力してください');
    }
    if (password.length < 6) {
      throw AuthValidationException('パスワードは6文字以上で入力してください');
    }
  }

  /// フォームバリデーション
  bool validateForm({required String email, required String password}) {
    _emailError = null;
    _passwordError = null;

    if (email.trim().isEmpty) {
      _emailError = '必須';
    }

    if (password.trim().isEmpty) {
      _passwordError = '必須';
    } else if (password.length < 6) {
      _passwordError = '6文字以上';
    }

    final isValid = _emailError == null && _passwordError == null;
    if (!isValid) {
      notifyListeners();
    }
    return isValid;
  }

  /// バリデーションエラーをクリア
  void clearValidationErrors() {
    _emailError = null;
    _passwordError = null;
    notifyListeners();
  }

  /// ログイン処理
  Future<void> signIn({
    required String email,
    required String password,
    String? redirectPath,
  }) async {
    _setLoading(true);
    _clearMessages();

    try {
      // バリデーション
      _validateSignInInput(email, password);

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
      if (e is AuthValidationException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'ログインに失敗しました';
      }
    } finally {
      _setLoading(false);
    }
  }

  /// サインアップ処理
  Future<void> signUp({required String email, required String password}) async {
    _setLoading(true);
    _clearMessages();

    try {
      // バリデーション
      _validateSignUpInput(email, password);

      final result = await AuthModel.signUp(email: email, password: password);

      if (result.isSuccess) {
        _successMessage = 'アカウントを作成しました';
        _shouldNavigate = true;
        _navigationPath = result.redirectPath;
      } else {
        _errorMessage = result.errorMessage;
      }
    } catch (e) {
      if (e is AuthValidationException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'アカウントの作成に失敗しました';
      }
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
