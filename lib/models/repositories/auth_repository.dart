// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

/// 認証に関するリポジトリ
class AuthRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// ログイン処理
  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  /// サインアップ処理
  Future<void> signUp({required String email, required String password}) async {
    await _client.auth.signUp(email: email, password: password);
  }

  /// ログアウト処理
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// 現在の認証状態を取得
  User? getCurrentUser() {
    return _client.auth.currentUser;
  }

  /// 認証状態の変更を監視
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  /// 現在のパスワードを確認
  Future<bool> verifyCurrentPassword(String currentPassword) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null || user.email == null) {
        throw Exception('ユーザーが認証されていません');
      }

      // 現在のパスワードを確認するため、一時的にサインインを試行
      await _client.auth.signInWithPassword(
        email: user.email!,
        password: currentPassword,
      );
      return true;
    } on AuthException catch (e) {
      // パスワードが間違っている場合
      if (e.message.contains('Invalid login credentials') ||
          e.message.contains('invalid_credentials')) {
        return false;
      }
      throw Exception('パスワード確認中にエラーが発生しました: ${e.message}');
    } catch (e) {
      throw Exception('パスワード確認中にエラーが発生しました: $e');
    }
  }

  /// 現在のメールアドレスを確認
  bool verifyCurrentEmail(String currentEmail) {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw Exception('ユーザーが認証されていません');
    }

    return user.email?.toLowerCase() == currentEmail.toLowerCase();
  }

  /// メールアドレス変更
  Future<void> changeUserEmail(String newEmail) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      await _client.auth.updateUser(UserAttributes(email: newEmail));
    } catch (e) {
      throw Exception('メールアドレスの変更に失敗しました: $e');
    }
  }

  /// パスワード変更
  Future<void> changeUserPassword(String newPassword) async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) {
        throw Exception('ユーザーが認証されていません');
      }

      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw Exception('パスワードの変更に失敗しました: $e');
    }
  }

  /// パスワードリセットメール送信
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      throw Exception('パスワードリセットメールの送信に失敗しました: $e');
    }
  }
}
