// Project imports:
import 'repositories/settings_repository.dart';
import 'repositories/auth_repository.dart';

/// 設定関連のビジネスロジックを担当するクラス
class Settings {
  // リフレクション頻度の定義（ビジネスルール）
  static const Map<String, int> _frequencyToId = {
    '週に1回': 3,
    '2週に1回': 2,
    '月に1回': 1,
  };

  static const Map<int, String> _idToFrequency = {
    1: '月に1回',
    2: '2週に1回',
    3: '週に1回',
  };

  /// 頻度文字列からIDに変換
  static int getReflectionTypeId(String frequency) {
    return _frequencyToId[frequency] ?? 2; // デフォルトは「2週に1回」
  }

  /// IDから頻度文字列に変換
  static String getFrequencyFromId(int id) {
    return _idToFrequency[id] ?? '2週に1回';
  }

  /// 頻度の説明文を取得
  static String getFrequencyDescription(String frequency) {
    switch (frequency) {
      case '週に1回':
        return 'こまめに記録する方におすすめ';
      case '2週に1回':
        return 'バランスのよい推奨設定';
      case '月に1回':
        return '記録する頻度が少ない方におすすめ';
      default:
        return '';
    }
  }

  /// パスワードバリデーション
  static String? validatePassword(String password, String confirmPassword) {
    if (password != confirmPassword) {
      return 'パスワードが一致しません';
    }
    if (password.length < 6) {
      return 'パスワードは6文字以上で入力してください';
    }
    return null;
  }

  /// メールアドレスバリデーション
  static String? validateEmail(String email) {
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

  /// 設定の初期化処理
  static Future<void> initialize({SettingsRepository? repository}) async {
    final repo = repository ?? SettingsRepository();

    try {
      // 設定データの初期化処理（必要に応じて）
      await repo.getUserSettings();
    } catch (e) {
      throw Exception('設定の読み込みに失敗しました: $e');
    }
  }

  /// 現在の設定を取得
  static Future<Map<String, dynamic>> getCurrentSettings({
    SettingsRepository? repository,
  }) async {
    final repo = repository ?? SettingsRepository();

    try {
      final settings = await repo.getUserSettings();
      return settings ?? {};
    } catch (e) {
      throw Exception('設定の読み込みに失敗しました: $e');
    }
  }

  /// リフレクション設定を保存
  static Future<void> saveReflectionSettings(
    String frequency, {
    SettingsRepository? repository,
  }) async {
    final repo = repository ?? SettingsRepository();
    final typeId = getReflectionTypeId(frequency);

    try {
      await repo.saveReflectionFrequency(typeId);
    } catch (e) {
      throw Exception('リフレクション設定の保存に失敗しました: $e');
    }
  }

  /// メールアドレス変更処理（AuthRepositoryを使用）
  static Future<void> changeEmail(
    String currentEmail,
    String newEmail, {
    AuthRepository? authRepository,
  }) async {
    final authRepo = authRepository ?? AuthRepository();

    // バリデーション
    final currentEmailError = validateEmail(currentEmail);
    if (currentEmailError != null) {
      throw Exception(currentEmailError);
    }

    final newEmailError = validateEmail(newEmail);
    if (newEmailError != null) {
      throw Exception(newEmailError);
    }

    try {
      await authRepo.changeUserEmail(newEmail);
    } catch (e) {
      throw Exception('メールアドレスの変更に失敗しました: $e');
    }
  }

  /// パスワード変更処理（AuthRepositoryを使用）
  static Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword, {
    AuthRepository? authRepository,
  }) async {
    final authRepo = authRepository ?? AuthRepository();

    // バリデーション
    final validationError = validatePassword(newPassword, confirmPassword);
    if (validationError != null) {
      throw Exception(validationError);
    }

    try {
      await authRepo.changeUserPassword(newPassword);
    } catch (e) {
      throw Exception('パスワードの変更に失敗しました: $e');
    }
  }

  /// ログアウト処理（AuthRepositoryを使用）
  static Future<void> signOut({AuthRepository? authRepository}) async {
    final authRepo = authRepository ?? AuthRepository();

    try {
      await authRepo.signOut();
    } catch (e) {
      throw Exception('ログアウトに失敗しました: $e');
    }
  }
}
