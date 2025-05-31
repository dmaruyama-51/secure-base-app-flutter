import 'kindness_record.dart';

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
