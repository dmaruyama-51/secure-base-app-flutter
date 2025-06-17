// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import '../utils/constants.dart';
import 'repositories/auth_repository.dart';

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
  static final AuthRepository _authRepository = AuthRepository();

  /// ログイン処理
  static Future<AuthResult> signIn({
    required String email,
    required String password,
    String? redirectPath,
  }) async {
    try {
      // AuthRepositoryを使用してログイン処理
      await _authRepository.signIn(email: email, password: password);

      // 成功時のリダイレクトパスを決定
      final destination = redirectPath ?? '/';

      return AuthResult.success(redirectPath: destination);
    } on AuthException catch (error) {
      return AuthResult.failure(error.message);
    } catch (error) {
      return AuthResult.failure(unexpectedErrorMessage);
    }
  }

  /// サインアップ処理
  static Future<AuthResult> signUp({
    required String email,
    required String password,
  }) async {
    try {
      // AuthRepositoryを使用してサインアップ処理
      await _authRepository.signUp(email: email, password: password);

      // 成功時はチュートリアルページにリダイレクト
      return AuthResult.success(redirectPath: '/tutorial');
    } on AuthException catch (error) {
      return AuthResult.failure(error.message);
    } catch (error) {
      return AuthResult.failure(unexpectedErrorMessage);
    }
  }
}
