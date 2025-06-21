// Project imports:
import 'repositories/user_repository.dart';
import 'kindness_reflection_model.dart';

/// ユーザー設定に関するビジネスロジック
class UserModel {
  static final UserRepository _userRepository = UserRepository();

  /// ユーザー設定を取得
  static Future<Map<String, dynamic>?> getUserSettings() async {
    try {
      return await _userRepository.getUserSettings();
    } catch (e) {
      throw Exception('ユーザー設定の取得に失敗しました: $e');
    }
  }

  /// リフレクション頻度を更新
  static Future<void> updateReflectionFrequency(String frequency) async {
    try {
      // 頻度文字列をIDに変換
      final typeId = await KindnessReflection.getReflectionTypeId(frequency);

      // ビジネスルール: 有効なIDかチェック
      if (typeId <= 0) {
        throw Exception('無効なリフレクション頻度が指定されました');
      }

      await _userRepository.updateReflectionFrequency(typeId);
    } catch (e) {
      // 既にExceptionの場合はそのまま再スロー
      if (e is Exception) {
        rethrow;
      }
      throw Exception('リフレクション頻度の更新に失敗しました: $e');
    }
  }

  /// 現在のリフレクション頻度を取得
  static Future<String> getCurrentReflectionFrequency() async {
    try {
      final settings = await _userRepository.getUserSettings();
      if (settings != null && settings['reflection_type_id'] != null) {
        final reflectionTypeId = settings['reflection_type_id'] as int;
        return await KindnessReflection.getFrequencyFromId(reflectionTypeId);
      }

      // デフォルト値を返す
      return '2週に1回';
    } catch (e) {
      // エラー時はデフォルト値を返す
      return '2週に1回';
    }
  }

  /// ユーザー設定を初期化
  static Future<void> initializeUserSettings() async {
    try {
      await _userRepository.getUserSettings();
    } catch (e) {
      throw Exception('ユーザー設定の初期化に失敗しました: $e');
    }
  }

  /// ユーザー設定の妥当性をチェック
  static Future<bool> validateUserSettings() async {
    try {
      final settings = await _userRepository.getUserSettings();

      // 基本的な妥当性チェック
      if (settings == null) {
        return false;
      }

      // リフレクション設定のチェック
      if (settings['reflection_type_id'] != null) {
        final reflectionTypeId = settings['reflection_type_id'] as int;
        if (reflectionTypeId <= 0) {
          return false;
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
