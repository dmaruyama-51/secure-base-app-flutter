import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// 現在のユーザー情報を提供するProvider
final currentUserProvider = StateProvider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

/// ログイン状態を監視するProvider
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// ユーザーがログインしているかどうかを判定するProvider
final isLoggedInProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (auth) => auth.session != null,
    loading: () => false,
    error: (_, __) => false,
  );
});
