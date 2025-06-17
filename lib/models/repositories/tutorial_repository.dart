// Package imports:
import 'package:shared_preferences/shared_preferences.dart';

// Project imports:
import '../settings_model.dart';

class TutorialRepository {
  static const String _hasCompletedTutorialKey = 'has_completed_tutorial';

  /// チュートリアルが完了しているかを確認
  Future<bool> hasCompletedTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasCompletedTutorialKey) ?? false;
  }

  /// チュートリアル完了をマーク
  Future<void> markTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasCompletedTutorialKey, true);
  }

  /// リフレクション頻度をDBに保存（Settingsに委譲）
  Future<void> saveReflectionFrequency(String frequency) async {
    try {
      await Settings.saveReflectionSettings(frequency);
    } catch (e) {
      throw Exception('リフレクション頻度の保存に失敗しました: $e');
    }
  }
}
