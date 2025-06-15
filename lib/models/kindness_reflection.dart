// Project imports:
import 'repositories/kindness_reflection_repository.dart';

class KindnessReflection {
  final int? id;
  final DateTime createdAt;
  final int? reflectionTypeId;
  final String? reflectionTitle;
  final DateTime? reflectionStartDate;
  final DateTime? reflectionEndDate;
  final String userId;

  // リポジトリのインスタンス
  static final KindnessReflectionRepository _repository =
      KindnessReflectionRepository();

  KindnessReflection({
    this.id,
    required this.createdAt,
    this.reflectionTypeId,
    this.reflectionTitle,
    this.reflectionStartDate,
    this.reflectionEndDate,
    required this.userId,
  });

  /// Supabaseの検索結果からKindnessReflectionオブジェクトを作成
  factory KindnessReflection.fromMap(Map<String, dynamic> map) {
    return KindnessReflection(
      id: map['id'],
      createdAt: DateTime.parse(map['created_at']),
      reflectionTypeId: map['reflection_type_id'],
      reflectionTitle: map['reflection_title'],
      reflectionStartDate:
          map['reflection_start_date'] != null
              ? DateTime.parse(map['reflection_start_date'])
              : null,
      reflectionEndDate:
          map['reflection_end_date'] != null
              ? DateTime.parse(map['reflection_end_date'])
              : null,
      userId: map['user_id'],
    );
  }

  /// KindnessReflectionオブジェクトをMapに変換
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'created_at': createdAt.toIso8601String(),
      if (reflectionTypeId != null) 'reflection_type_id': reflectionTypeId,
      if (reflectionTitle != null) 'reflection_title': reflectionTitle,
      if (reflectionStartDate != null)
        'reflection_start_date': reflectionStartDate!.toIso8601String(),
      if (reflectionEndDate != null)
        'reflection_end_date': reflectionEndDate!.toIso8601String(),
      'user_id': userId,
    };
  }

  /// リフレクションを「最新」と「過去」にグループ分け
  /// リフレクションが1つしかない場合は、それを最新として扱う
  static Map<String, List<KindnessReflection>> groupReflections(
    List<KindnessReflection> reflections,
  ) {
    final now = DateTime.now();
    final sevenDaysAgo = DateTime(now.year, now.month, now.day - 7);

    final latestReflections = <KindnessReflection>[];
    final pastReflections = <KindnessReflection>[];

    // リフレクションが1つしかない場合は、それを最新として扱う
    if (reflections.length == 1) {
      latestReflections.add(reflections.first);
    } else {
      // 複数ある場合は通常通り7日以内かどうかで分ける
      for (final reflection in reflections) {
        if (reflection.createdAt.isAfter(sevenDaysAgo)) {
          latestReflections.add(reflection);
        } else {
          pastReflections.add(reflection);
        }
      }
    }

    return {'latest': latestReflections, 'past': pastReflections};
  }

  /// 現在のユーザーのリフレクション一覧を取得
  static Future<List<KindnessReflection>> fetchReflections({
    int limit = 50,
    int offset = 0,
  }) async {
    return await _repository.fetchReflections(limit: limit, offset: offset);
  }

  /// 特定のリフレクションを取得
  static Future<KindnessReflection?> getReflectionById(int id) async {
    return await _repository.getReflectionById(id);
  }
}
