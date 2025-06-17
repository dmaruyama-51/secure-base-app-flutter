// Project imports:
import 'repositories/kindness_reflection_repository.dart';
import 'repositories/user_repository.dart';

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
  static final UserRepository _userRepository = UserRepository();

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

  /// 次回リフレクション配信日を計算する
  static Future<DateTime> calculateNextDeliveryDate({
    List<KindnessReflection>? existingReflections,
    KindnessReflectionRepository? reflectionRepository,
    UserRepository? userRepository,
  }) async {
    final reflectionRepo = reflectionRepository ?? _repository;
    final userRepo = userRepository ?? _userRepository;

    try {
      // リフレクション期間を取得
      final reflectionPeriod = await reflectionRepo.getReflectionPeriod();

      DateTime baseDate;

      // 既存のリフレクションがある場合は最新のcreated_atを基準にする
      if (existingReflections != null && existingReflections.isNotEmpty) {
        baseDate = existingReflections.first.createdAt;
      } else {
        // リフレクションがない場合はユーザーのサインアップ日を基準にする
        baseDate = await userRepo.getUserCreatedAt();
      }

      // 基準日に期間を足して次回配信日を計算
      return baseDate.add(Duration(days: reflectionPeriod));
    } catch (e) {
      throw Exception('次回配信日の計算に失敗しました: $e');
    }
  }
}
