class KindnessRecord {
  final int? id;
  final String userId;
  final int? giverId;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String giverName; // kindness_giversテーブルから取得する情報
  final String? giverAvatarUrl; // kindness_giversテーブルから取得する情報
  final String giverCategory; // kindness_giversテーブルから取得する情報（必須）
  final String giverGender; // kindness_giversテーブルから取得する情報（必須）

  KindnessRecord({
    this.id,
    required this.userId,
    required this.giverId,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
    required this.giverName,
    this.giverAvatarUrl,
    required this.giverCategory,
    required this.giverGender,
  });
}