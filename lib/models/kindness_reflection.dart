import 'kindness_record.dart';

// Reflectionアイテムのデータモデル
class KindnessReflection {
  final int? id;
  final String userId;
  final int? reflectionTypeId;
  final String? reflectionType;
  final String? reflectionTitle;
  final DateTime? reflectionStartDate;
  final DateTime? reflectionEndDate;
  final DateTime? createdAt;

  KindnessReflection({
    this.id,
    required this.userId,
    this.reflectionTypeId,
    this.reflectionType,
    this.reflectionTitle,
    this.reflectionStartDate,
    this.reflectionEndDate,
    this.createdAt,
  });

  // データベースのMapからKindnessReflectionを生成
  factory KindnessReflection.fromMap(
    Map<String, dynamic> map, {
    String? reflectionTypeName,
  }) {
    return KindnessReflection(
      id: map['id'] as int?,
      userId: map['user_id'] as String,
      reflectionTypeId: map['reflection_type_id'] as int?,
      reflectionType:
          reflectionTypeName ?? map['reflection_type_name'] as String?,
      reflectionTitle: map['reflection_title'] as String?,
      reflectionStartDate:
          map['reflection_start_date'] != null
              ? DateTime.parse(map['reflection_start_date'].toString())
              : null,
      reflectionEndDate:
          map['reflection_end_date'] != null
              ? DateTime.parse(map['reflection_end_date'].toString())
              : null,
      createdAt:
          map['created_at'] != null
              ? DateTime.parse(map['created_at'].toString())
              : null,
    );
  }

  // KindnessReflectionをMapに変換（データベース保存用）
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'reflection_type_id': reflectionTypeId,
      'reflection_title': reflectionTitle,
      'reflection_start_date':
          reflectionStartDate?.toIso8601String().split('T')[0],
      'reflection_end_date': reflectionEndDate?.toIso8601String().split('T')[0],
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }
}

// Reflection Summary画面のデータモデル
class ReflectionSummaryData {
  final String title;
  final int entriesCount;
  final int daysCount;
  final int peopleCount;
  final List<KindnessRecord> records; // KindnessRecordを直接使用

  ReflectionSummaryData({
    required this.title,
    required this.entriesCount,
    required this.daysCount,
    required this.peopleCount,
    required this.records,
  });
}

// 統計情報を分離
class SummaryStatistics {
  final int entriesCount;
  final int daysCount;
  final int peopleCount;

  SummaryStatistics({
    required this.entriesCount,
    required this.daysCount,
    required this.peopleCount,
  });

  // KindnessRecordリストから統計を自動計算
  factory SummaryStatistics.fromRecords(List<KindnessRecord> records) {
    final entriesCount = records.length;
    final uniqueDays =
        records
            .map(
              (r) => DateTime(
                r.createdAt.year,
                r.createdAt.month,
                r.createdAt.day,
              ),
            )
            .toSet()
            .length;
    final uniquePeople = records.map((r) => r.giverId).toSet().length;

    return SummaryStatistics(
      entriesCount: entriesCount,
      daysCount: uniqueDays,
      peopleCount: uniquePeople,
    );
  }
}
