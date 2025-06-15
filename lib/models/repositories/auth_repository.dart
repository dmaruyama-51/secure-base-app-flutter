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
}
