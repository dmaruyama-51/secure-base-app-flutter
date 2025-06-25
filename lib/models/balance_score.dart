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
