// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../utils/app_colors.dart';

/// バランススコアの状態を表す列挙型
enum BalanceStatus {
  supporting, // 支えることが多め（0-29）
  balanced, // バランスが取れている（30-70）
  supported, // 支えられることが多め（71-100）
}

class BalanceScore {
  final int id;
  final DateTime createdAt;
  final String userId;
  final DateTime? weekStartDate;
  final DateTime? weekEndDate;
  final int sentCount;
  final int sentUu;
  final int receiveCount;
  final int receiveUu;
  final int supportingScore;
  final int supportedScore;
  final double supportingScoreNorm;
  final double supportedScoreNorm;
  final int balanceScore;

  BalanceScore({
    required this.id,
    required this.createdAt,
    required this.userId,
    this.weekStartDate,
    this.weekEndDate,
    required this.sentCount,
    required this.sentUu,
    required this.receiveCount,
    required this.receiveUu,
    required this.supportingScore,
    required this.supportedScore,
    required this.supportingScoreNorm,
    required this.supportedScoreNorm,
    required this.balanceScore,
  });

  /// バランススコアの状態を取得
  BalanceStatus get balanceStatus {
    if (balanceScore >= 30 && balanceScore <= 70) {
      return BalanceStatus.balanced;
    } else if (balanceScore > 70) {
      return BalanceStatus.supported;
    } else {
      return BalanceStatus.supporting;
    }
  }

  /// バランス状態に対応するメッセージを取得
  String get statusMessage {
    switch (balanceStatus) {
      case BalanceStatus.balanced:
        return 'バランスが取れています';
      case BalanceStatus.supported:
        return '支えられることが多め';
      case BalanceStatus.supporting:
        return '支えることが多め';
    }
  }

  /// 50点からの距離を計算（0.0-1.0の範囲）
  double get distanceFromCenter {
    return (balanceScore - 50).abs() / 50.0;
  }

  /// バランススコアに基づいて色を計算
  Color getScoreColor() {
    return Color.lerp(
          AppColors.balanceCenter,
          AppColors.balanceEdge,
          distanceFromCenter,
        ) ??
        AppColors.primary;
  }

  /// バランスゾーンにいるかどうかを判定
  bool get isInBalanceZone {
    return balanceStatus == BalanceStatus.balanced;
  }

  /// チャート表示用のグラデーション色を取得
  static List<Color> getChartGradientColors() {
    return AppColors.balanceGradientColors;
  }

  /// チャート表示用のグラデーション停止点を取得
  static List<double> getChartGradientStops() {
    return AppColors.balanceGradientStops;
  }

  factory BalanceScore.fromJson(Map<String, dynamic> json) {
    try {
      return BalanceScore(
        id: json['id'] as int,
        createdAt: DateTime.parse(json['created_at'] as String),
        userId: json['user_id'] as String,
        weekStartDate:
            json['week_start_date'] != null
                ? DateTime.parse(json['week_start_date'] as String)
                : null,
        weekEndDate:
            json['week_end_date'] != null
                ? DateTime.parse(json['week_end_date'] as String)
                : null,
        sentCount: json['sent_count'] as int? ?? 0,
        sentUu: json['sent_uu'] as int? ?? 0,
        receiveCount: json['receive_count'] as int? ?? 0,
        receiveUu: json['reveive_uu'] as int? ?? 0, // テーブル側のtypo に合わせる
        supportingScore: json['supporting_score'] as int? ?? 0,
        supportedScore: json['supported_score'] as int? ?? 0,
        supportingScoreNorm:
            (json['supporting_score_norm'] as num?)?.toDouble() ?? 0.0,
        supportedScoreNorm:
            (json['supported_score_norm'] as num?)?.toDouble() ?? 0.0,
        balanceScore: json['balance_score'] as int? ?? 0,
      );
    } catch (e) {
      throw Exception('BalanceScore JSON パースエラー: $e, データ: $json');
    }
  }
}
