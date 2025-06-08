import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

/// 設定画面の状態クラス
@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(false) bool isLoading,
    String? errorMessage,
    String? successMessage,
  }) = _SettingsState;
}
