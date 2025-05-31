// Reflectionアイテムのデータモデル
class KindnessReflection {
  final int? id;
  final int userId;
  final int reflectionTypeId;
  final String reflectionType;
  final String reflectionTitle;
  final DateTime reflectionStartDate;
  final DateTime reflectionEndDate;
  final DateTime? createdAt;

  KindnessReflection({
    this.id,
    required this.userId,
    required this.reflectionTypeId,
    required this.reflectionType,
    required this.reflectionTitle,
    required this.reflectionStartDate,
    required this.reflectionEndDate,
    this.createdAt,
  });
}
