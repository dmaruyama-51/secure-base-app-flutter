import 'package:shared_preferences/shared_preferences.dart';

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

  /// チュートリアル状態をリセット（デバッグ用）
  Future<void> resetTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_hasCompletedTutorialKey);
  }
}
