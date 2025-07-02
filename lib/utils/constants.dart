// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase にアクセスするためのクライアントインスタンス
final supabase = Supabase.instance.client;

/// 予期せぬエラーが起きた際のエラーメッセージ
const unexpectedErrorMessage = '予期せぬエラーが起きました';

/// アプリ全体で統一的な角丸のための定数
class AppBorderRadius {
  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;
  static const double extraLarge = 20.0;

  // よく使用される BorderRadius
  static const BorderRadius smallRadius = BorderRadius.all(
    Radius.circular(small),
  );
  static const BorderRadius mediumRadius = BorderRadius.all(
    Radius.circular(medium),
  );
  static const BorderRadius largeRadius = BorderRadius.all(
    Radius.circular(large),
  );
  static const BorderRadius extraLargeRadius = BorderRadius.all(
    Radius.circular(extraLarge),
  );
}

/// Snackbarを楽に表示させるための拡張メソッド
extension ShowSnackBar on BuildContext {
  /// 標準的なSnackbarを表示
  void showSnackBar({
    required String message,
    Color backgroundColor = Colors.white,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: backgroundColor),
    );
  }

  /// エラーが起きた際のSnackbarを表示
  void showErrorSnackBar({required String message}) {
    showSnackBar(
      message: message,
      backgroundColor: Theme.of(this).colorScheme.error,
    );
  }
}
