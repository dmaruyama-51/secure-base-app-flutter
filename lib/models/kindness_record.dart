class KindnessRecord {
  final int? id;
  final String userId;
  final int giverId;
  final String? content;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String giverName; // kindness_giversテーブルから取得する情報
  final String? giverAvatarUrl; // kindness_giversテーブルから取得する情報

  KindnessRecord({
    this.id,
    required this.userId,
    required this.giverId,
    this.content,
    required this.createdAt,
    this.updatedAt,
    required this.giverName,
    this.giverAvatarUrl,
  });
}
