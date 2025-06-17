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
