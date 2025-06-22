// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

// Project imports:
import '../../models/user_model.dart';
import '../../models/auth_model.dart';
import '../../models/kindness_reflection.dart';

/// 設定のViewModel（プレゼンテーションロジックと状態管理に特化）
class SettingsViewModel extends ChangeNotifier {
  // UI状態プロパティ
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // ダイアログ状態
  bool _showEmailDialog = false;
  bool _showPasswordDialog = false;
  bool _showReflectionDialog = false;

  // 入力値の状態
  String _currentEmail = '';
  String _newEmail = '';
  String _currentPassword = '';
  String _newPassword = '';
  String _confirmPassword = '';

  // リフレクション設定の状態
  String _selectedReflectionFrequency = '2週に1回';
  bool _isLoadingReflectionSettings = false;

  // ゲッター（UI状態の公開）
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  bool get showEmailDialog => _showEmailDialog;
  bool get showPasswordDialog => _showPasswordDialog;
  bool get showReflectionDialog => _showReflectionDialog;
  String get currentEmail => _currentEmail;
  String get newEmail => _newEmail;
  String get currentPassword => _currentPassword;
  String get newPassword => _newPassword;
  String get confirmPassword => _confirmPassword;
  String get selectedReflectionFrequency => _selectedReflectionFrequency;
  bool get isLoadingReflectionSettings => _isLoadingReflectionSettings;

  // バリデーションメソッド

  /// パスワードバリデーション
  String? _validatePassword(String password, String confirmPassword) {
    if (password != confirmPassword) {
      return 'パスワードが一致しません';
    }
    if (password.length < 6) {
      return 'パスワードは6文字以上で入力してください';
    }
    return null;
  }

  /// メールアドレスバリデーション
  String? _validateEmail(String email) {
    if (email.trim().isEmpty) {
      return 'メールアドレスを入力してください';
    }
    // 簡単なメールアドレス形式チェック
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      return '正しいメールアドレス形式で入力してください';
    }
    return null;
  }

  // ダイアログ表示メソッド
  void showEmailChangeDialog() {
    _showEmailDialog = true;
    _currentEmail = '';
    _newEmail = '';
    notifyListeners();
  }

  void showPasswordChangeDialog() {
    _showPasswordDialog = true;
    _currentPassword = '';
    _newPassword = '';
    _confirmPassword = '';
    notifyListeners();
  }

  Future<void> showReflectionSettingsDialog() async {
    _showReflectionDialog = true;
    _isLoadingReflectionSettings = true;
    notifyListeners();

    try {
      // UserModelを使用して現在の設定を読み込み
      _selectedReflectionFrequency =
          await UserModel.getCurrentReflectionFrequency();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingReflectionSettings = false;
      notifyListeners();
    }
  }

  void closeDialogs() {
    _showEmailDialog = false;
    _showPasswordDialog = false;
    _showReflectionDialog = false;
    notifyListeners();
  }

  // 入力値更新メソッド
  void updateCurrentEmail(String email) {
    _currentEmail = email;
    notifyListeners();
  }

  void updateNewEmail(String email) {
    _newEmail = email;
    notifyListeners();
  }

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

  void updateReflectionFrequency(String frequency) {
    _selectedReflectionFrequency = frequency;
    notifyListeners();
  }

  Future<void> changeEmail() async {
    _setLoading(true);
    _clearMessages();

    try {
      // バリデーション
      final currentEmailError = _validateEmail(_currentEmail);
      if (currentEmailError != null) {
        _errorMessage = currentEmailError;
        return;
      }

      final newEmailError = _validateEmail(_newEmail);
      if (newEmailError != null) {
        _errorMessage = newEmailError;
        return;
      }

      // AuthModelを使用してメールアドレス変更
      await AuthModel.changeEmail(_currentEmail, _newEmail);
      _successMessage = 'メールアドレスを変更しました';
      _showEmailDialog = false;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePassword() async {
    _setLoading(true);
    _clearMessages();

    try {
      // バリデーション
      final validationError = _validatePassword(_newPassword, _confirmPassword);
      if (validationError != null) {
        _errorMessage = validationError;
        return;
      }

      // 現在のパスワードが空でないかチェック
      if (_currentPassword.trim().isEmpty) {
        _errorMessage = '現在のパスワードを入力してください';
        return;
      }

      // AuthModelを使用してパスワード変更
      await AuthModel.changePassword(
        _currentPassword,
        _newPassword,
        _confirmPassword,
      );
      _successMessage = 'パスワードを変更しました';
      _showPasswordDialog = false;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveReflectionSettings() async {
    _isLoadingReflectionSettings = true;
    _clearMessages();
    notifyListeners();

    try {
      await UserModel.updateReflectionFrequency(_selectedReflectionFrequency);
      _successMessage = 'リフレクション設定を保存しました';
      _showReflectionDialog = false;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingReflectionSettings = false;
      notifyListeners();
    }
  }

  Future<void> initialize() async {
    _setLoading(true);
    _clearMessages();

    try {
      await UserModel.initializeUserSettings();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    _clearMessages();

    try {
      // AuthModelを使用してログアウト
      await AuthModel.signOut();
      _successMessage = 'ログアウトしました';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // プレゼンテーション用メソッド（KindnessReflectionのビジネスロジックを使用）
  Future<String> getFrequencyDescription(String frequency) async {
    return await KindnessReflection.getFrequencyDescription(frequency);
  }

  // ヘルパーメソッド
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  Future<void> openPrivacyPolicy() async {
    final uri = Uri.parse(
      'https://www.notion.so/21693295f40f8012af28c9488fe6a69c?source=copy_link',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _errorMessage = 'リンクを開けませんでした';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'エラーが発生しました';
      notifyListeners();
    }
  }

  Future<void> openFeedbackForm() async {
    final uri = Uri.parse('https://forms.gle/fFH7A5BeKaEvX7ur6');

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _errorMessage = 'フィードバックフォームを開けませんでした';
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'エラーが発生しました';
      notifyListeners();
    }
  }
}
