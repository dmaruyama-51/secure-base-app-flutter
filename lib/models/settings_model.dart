import '../repositories/auth_repository.dart';

/// 設定関連のビジネスロジックを担当するクラス
class Settings {
  /// 設定の初期化処理
  static Future<void> initialize() async {
    try {
      // 設定データの読み込みなど
      await Future.delayed(Duration(seconds: 1)); // 模擬的な処理
    } catch (e) {
      throw Exception('設定の読み込みに失敗しました: $e');
    }
  }

  /// ログアウト処理
  static Future<void> signOut({AuthRepository? repository}) async {
    final repo = repository ?? AuthRepository();

    try {
      await repo.signOut();
    } catch (e) {
      throw Exception('ログアウトに失敗しました: $e');
    }
  }
}
