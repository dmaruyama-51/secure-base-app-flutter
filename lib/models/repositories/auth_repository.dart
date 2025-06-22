// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

/// 認証に関するデータアクセス層
class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// サインイン
  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  /// サインアップ
  Future<void> signUpWithEmailAndPassword(String email, String password) async {
    await _supabase.auth.signUp(email: email, password: password);
  }

  /// メールアドレス変更
  Future<void> updateUserEmail(String newEmail) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('ユーザーが認証されていません');
    }

    await _supabase.auth.updateUser(UserAttributes(email: newEmail));
  }

  /// パスワード変更
  Future<void> updateUserPassword(String newPassword) async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      throw Exception('ユーザーが認証されていません');
    }

    await _supabase.auth.updateUser(UserAttributes(password: newPassword));
  }

  /// サインアウト
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// 現在のユーザーを取得
  User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }

  /// 認証状態の変更を監視
  Stream<AuthState> get onAuthStateChange {
    return _supabase.auth.onAuthStateChange;
  }

  /// パスワードリセットメール送信
  Future<void> resetPasswordForEmail(String email) async {
    await _supabase.auth.resetPasswordForEmail(email);
  }
}
