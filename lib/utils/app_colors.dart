// Flutter imports:
import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFFE5781A);
  static const Color primaryLight = Color(0xFFF2D2B7);
  static const Color secondary = Color(0xFFF2EDE8);

  // 背景
  static const Color background = Color(0xFFFCFAF7);

  // テキスト
  static const Color text = Color(0xFF1C140D);
  static const Color textLight = Color(0xFF96704F);
  static const Color textOnPrimary = Colors.white; // プライマリカラー上のテキスト色

  // サーフェス
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // アウトライン・ボーダー
  static const Color outline = Color(0xFFE0E0E0);
  static const Color outlineLight = Color(0xFFF0F0F0);

  // システムカラー
  static const Color error = Colors.red;
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // バランススコア専用カラー
  static const Color balanceCenter = Color(0xFFFFB366); // 明るいオレンジ（50点）
  static const Color balanceEdge = Color(0xFFB8540F); // 濃いオレンジ（端）
  static const Color balanceGradient1 = Color(0xFFB8540F); // 0点側
  static const Color balanceGradient2 = Color(0xFFD16515); // 25点付近
  static const Color balanceGradient3 = Color(0xFFFFB366); // 50点中央

  // 統計チャート用カラーパレット
  static const List<Color> chartColors = [
    Color(0xFF2196F3), // 青
    Color(0xFF9C27B0), // 紫
    Color(0xFFFF9800), // オレンジ
    Color(0xFF4CAF50), // 緑
    Color(0xFFE91E63), // ピンク
  ];

  // グレースケール
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  /// 軽いシャドウカラー（透明度4%）
  static Color get lightShadow => Colors.black.withOpacity(0.04);

  /// 中程度のシャドウカラー（透明度6%）
  static Color get mediumShadow => Colors.black.withOpacity(0.06);

  /// 標準的なシャドウカラー（透明度10%）
  static Color get shadow => Colors.black.withOpacity(0.10);

  /// バランススコア用グラデーションカラーリスト
  static List<Color> get balanceGradientColors => [
    balanceGradient1, // 0点側（濃いオレンジ）
    balanceGradient2, // 25点付近（中間の濃さ）
    balanceGradient3, // 50点中央（明るいオレンジ）
    balanceGradient2, // 75点付近（中間の濃さ）
    balanceGradient1, // 100点側（濃いオレンジ）
  ];

  /// バランススコア用グラデーション停止点
  static List<double> get balanceGradientStops => [0.0, 0.2, 0.5, 0.8, 1.0];

  /// チャートカラーを取得（ハッシュベース）
  static Color getChartColor(String key) {
    return chartColors[key.hashCode.abs() % chartColors.length];
  }
}
