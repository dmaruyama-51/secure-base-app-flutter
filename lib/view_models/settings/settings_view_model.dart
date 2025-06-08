import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../states/settings/settings_state.dart';

/// 設定画面のViewModel
class SettingsViewModel extends StateNotifier<SettingsState> {
  SettingsViewModel() : super(const SettingsState());

  /// ログアウト処理
  Future<void> signOut() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      successMessage: null,
    );

    try {
      await Supabase.instance.client.auth.signOut();

      state = state.copyWith(isLoading: false, successMessage: 'ログアウトしました');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'ログアウトに失敗しました: ${e.toString()}',
      );
    }
  }

  /// エラーメッセージをクリア
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

/// 設定画面ViewModelのProvider
final settingsViewModelProvider =
    StateNotifierProvider<SettingsViewModel, SettingsState>(
      (ref) => SettingsViewModel(),
    );
