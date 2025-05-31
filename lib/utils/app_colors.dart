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

  // Reflection関連の色を追加
  static const Color reflectionCardBackground = Color(0xFFFAF7F2); // カード背景色
  static const Color reflectionCardBorder = Color(0xFFE8DDD4); // カードボーダー色
  static const Color reflectionIconColor = Color(
    0xFF96704F,
  ); // アイコン色（textLightと同じ）
}
