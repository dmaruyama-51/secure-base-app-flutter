// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../utils/constants.dart';

/// 認証バリデーションエラー用の例外クラス
class AuthValidationException implements Exception {
  final String message;

  AuthValidationException(this.message);

  @override
  String toString() => message;
}

/// 認証結果を表すクラス
class AuthResult {
  final bool isSuccess;
  final String? errorMessage;
  final String? redirectPath;

  AuthResult({required this.isSuccess, this.errorMessage, this.redirectPath});

  AuthResult.success({this.redirectPath})
    : isSuccess = true,
      errorMessage = null;
  AuthResult.failure(this.errorMessage)
    : isSuccess = false,
      redirectPath = null;
}

/// 認証関連のビジネスロジックを管理するModel
class AuthModel {
  /// ログイン処理
  static Future<AuthResult> signIn({
    required String email,
    required String password,
    String? redirectPath,
  }) async {
    try {
      // 入力バリデーション
      _validateSignInInput(email, password);

      // Supabase認証
      await supabase.auth.signInWithPassword(email: email, password: password);

      // 成功時のリダイレクトパスを決定
      final destination = redirectPath ?? '/';

      return AuthResult.success(redirectPath: destination);
    } on AuthException catch (error) {
      return AuthResult.failure(error.message);
    } catch (error) {
      if (error is AuthValidationException) {
        return AuthResult.failure(error.message);
      }
      return AuthResult.failure(unexpectedErrorMessage);
    }
  }

  /// サインアップ処理
  static Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    try {
      // 入力バリデーション
      _validateSignUpInput(email, password);

      // Supabase認証
      await supabase.auth.signUp(email: email, password: password);

      // 成功時はチュートリアルページにリダイレクト
      return AuthResult.success(redirectPath: '/tutorial');
    } on AuthException catch (error) {
      return AuthResult.failure(error.message);
    } catch (error) {
      if (error is AuthValidationException) {
        return AuthResult.failure(error.message);
      }
      return AuthResult.failure(unexpectedErrorMessage);
    }
  }

  /// ログイン用入力バリデーション
  static void _validateSignInInput(String email, String password) {
    if (email.trim().isEmpty) {
      throw AuthValidationException('メールアドレスを入力してください');
    }
    if (password.trim().isEmpty) {
      throw AuthValidationException('パスワードを入力してください');
    }
  }

  /// サインアップ用入力バリデーション
  static void _validateSignUpInput(String email, String password) {
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
}
