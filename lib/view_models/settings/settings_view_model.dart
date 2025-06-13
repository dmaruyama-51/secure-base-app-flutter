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

  // ダイアログ状態
  bool _showEmailDialog = false;
  bool _showPasswordDialog = false;
  String _currentEmail = '';
  String _newEmail = '';
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  // ゲッター
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get showEmailDialog => _showEmailDialog;
  bool get showPasswordDialog => _showPasswordDialog;
  String get currentEmail => _currentEmail;
  String get newEmail => _newEmail;
  String get currentPassword => _currentPassword;
  String get newPassword => _newPassword;
  String get confirmPassword => _confirmPassword;

  /// メールアドレス変更ダイアログを表示
  void showEmailChangeDialog() {
    _showEmailDialog = true;
    _currentEmail = '';
    _newEmail = '';
    notifyListeners();
  }

  /// パスワード変更ダイアログを表示
  void showPasswordChangeDialog() {
    _showPasswordDialog = true;
    _currentPassword = '';
    _newPassword = '';
    _confirmPassword = '';
    notifyListeners();
  }

  /// ダイアログを閉じる
  void closeDialogs() {
    _showEmailDialog = false;
    _showPasswordDialog = false;
    notifyListeners();
  }

  /// メールアドレス入力を更新
  void updateCurrentEmail(String email) {
    _currentEmail = email;
    notifyListeners();
  }

  void updateNewEmail(String email) {
    _newEmail = email;
    notifyListeners();
  }

  /// パスワード入力を更新
  void updateCurrentPassword(String password) {
    _currentPassword = password;
    notifyListeners();
  }

  void updateNewPassword(String password) {
    _newPassword = password;
    notifyListeners();
  }

  void updateConfirmPassword(String password) {
    _confirmPassword = password;
    notifyListeners();
  }

  /// メールアドレス変更処理
  Future<void> changeEmail() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: 実際のメールアドレス変更処理を実装
      await Future.delayed(const Duration(seconds: 1));
      _isLoading = false;
      _successMessage = 'メールアドレスの変更機能は実装予定です';
      _showEmailDialog = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'メールアドレスの変更に失敗しました';
      notifyListeners();
    }
  }

  /// パスワード変更処理
  Future<void> changePassword() async {
    // バリデーション
    if (_newPassword != _confirmPassword) {
      _errorMessage = 'パスワードが一致しません';
      notifyListeners();
      return;
    }

    if (_newPassword.length < 6) {
      _errorMessage = 'パスワードは6文字以上で入力してください';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // TODO: 実際のパスワード変更処理を実装
      await Future.delayed(const Duration(seconds: 1));
      _isLoading = false;
      _successMessage = 'パスワードの変更機能は実装予定です';
      _showPasswordDialog = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'パスワードの変更に失敗しました';
      notifyListeners();
    }
  }

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
