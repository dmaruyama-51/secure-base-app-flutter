import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../states/settings/settings_state.dart';

/// 設定画面のViewModel
class SettingsViewModel extends ChangeNotifier {
  SettingsState _state = const SettingsState();

  SettingsState get state => _state;

  void _updateState(SettingsState newState) {
    _state = newState;
    notifyListeners();
  }

  /// ログアウト処理
  Future<void> signOut() async {
    _updateState(
      _state.copyWith(
        isLoading: true,
        errorMessage: null,
        successMessage: null,
      ),
    );

    try {
      await Supabase.instance.client.auth.signOut();
      _updateState(
        _state.copyWith(isLoading: false, successMessage: 'ログアウトしました'),
      );
    } catch (e) {
      _updateState(
        _state.copyWith(
          isLoading: false,
          errorMessage: 'ログアウトに失敗しました: ${e.toString()}',
        ),
      );
    }
  }

  /// エラーメッセージをクリア
  void clearMessages() {
    _updateState(_state.copyWith(errorMessage: null, successMessage: null));
  }
}
