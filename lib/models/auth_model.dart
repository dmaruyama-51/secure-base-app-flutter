// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

// Project imports:
import 'repositories/auth_repository.dart';

/// 認証・アカウント管理に関するビジネスロジック
class AuthModel {
  static final AuthRepository _authRepository = AuthRepository();

  /// サインイン
  static Future<void> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await _authRepository.signInWithEmailAndPassword(email, password);
    } on AuthException catch (e) {
      throw Exception('ログインに失敗しました: ${e.message}');
    } catch (e) {
      throw Exception('ログインエラー: $e');
    }
  }

  /// サインアップ
  static Future<void> signUpWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      await _authRepository.signUpWithEmailAndPassword(email, password);
    } on AuthException catch (e) {
      throw Exception('アカウント作成に失敗しました: ${e.message}');
    } catch (e) {
      throw Exception('アカウント作成エラー: $e');
    }
  }

  /// メールアドレス変更
  static Future<void> changeEmail(String currentEmail, String newEmail) async {
    try {
      // ビジネスルール: 現在のメールアドレスが正しいことを確認
      final currentUser = _authRepository.getCurrentUser();
      if (currentUser?.email?.toLowerCase() != currentEmail.toLowerCase()) {
        throw Exception('現在のメールアドレスが正しくありません');
      }

      // ビジネスルール: 新しいメールアドレスが現在のものと異なることを確認
      if (currentEmail.toLowerCase() == newEmail.toLowerCase()) {
        throw Exception('新しいメールアドレスは現在のものと異なる必要があります');
      }

      await _authRepository.updateUserEmail(newEmail);
    } on AuthException catch (e) {
      throw Exception('メールアドレス変更に失敗しました: ${e.message}');
    } catch (e) {
      // 既にExceptionの場合はそのまま再スロー
      if (e is Exception) {
        rethrow;
      }
      throw Exception('メールアドレス変更エラー: $e');
    }
  }

  /// パスワード変更
  static Future<void> changePassword(
    String currentPassword,
    String newPassword,
    String confirmPassword,
  ) async {
    try {
      // ビジネスルール: 新しいパスワードが現在のものと異なることを確認
      if (currentPassword == newPassword) {
        throw Exception('新しいパスワードは現在のものと異なる必要があります');
      }

      // ビジネスルール: パスワード確認の一致チェック
      if (newPassword != confirmPassword) {
        throw Exception('パスワードが一致しません');
      }

      // 現在のパスワードを確認するため、再認証を試行
      final currentUser = _authRepository.getCurrentUser();
      if (currentUser?.email == null) {
        throw Exception('ユーザー情報を取得できません');
      }

      // 現在のパスワードの確認
      await _authRepository.signInWithEmailAndPassword(
        currentUser!.email!,
        currentPassword,
      );

      // パスワード更新
      await _authRepository.updateUserPassword(newPassword);
    } on AuthException catch (e) {
      // 現在のパスワードが間違っている場合
      if (e.message.contains('Invalid login credentials') ||
          e.message.contains('invalid_credentials')) {
        throw Exception('現在のパスワードが正しくありません');
      }
      throw Exception('パスワード変更に失敗しました: ${e.message}');
    } catch (e) {
      // 既にExceptionの場合はそのまま再スロー
      if (e is Exception) {
        rethrow;
      }
      throw Exception('パスワード変更エラー: $e');
    }
  }

  /// サインアウト
  static Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (e) {
      throw Exception('ログアウトエラー: $e');
    }
  }

  /// 現在のユーザーを取得
  static User? getCurrentUser() {
    return _authRepository.getCurrentUser();
  }

  /// 認証状態の変更を監視
  static Stream<AuthState> get onAuthStateChange {
    return _authRepository.onAuthStateChange;
  }

  /// パスワードリセット
  static Future<void> resetPassword(String email) async {
    try {
      await _authRepository.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      throw Exception('パスワードリセットメールの送信に失敗しました: ${e.message}');
    } catch (e) {
      throw Exception('パスワードリセットエラー: $e');
    }
  }
}
