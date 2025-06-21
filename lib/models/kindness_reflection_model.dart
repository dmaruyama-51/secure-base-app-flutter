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

  /// 頻度文字列からIDに変換
  static Future<int> getReflectionTypeId(String frequency) async {
    try {
      final id = await _repository.getReflectionTypeIdByName(frequency);
      return id ?? 2; // デフォルトは「2週に1回」のID
    } catch (e) {
      // エラー時はデフォルト値を返す
      return 2;
    }
  }

  /// IDから頻度文字列に変換
  static Future<String> getFrequencyFromId(int id) async {
    try {
      final name = await _repository.getReflectionTypeNameById(id);
      return name ?? '2週に1回'; // デフォルト
    } catch (e) {
      // エラー時はデフォルト値を返す
      return '2週に1回';
    }
  }

  /// 頻度の説明文を取得
  static String getFrequencyDescription(String frequency) {
    switch (frequency) {
      case '週に1回':
        return 'こまめに記録する方におすすめ';
      case '2週に1回':
        return 'バランスのよい推奨設定';
      case '月に1回':
        return '記録する頻度が少ない方におすすめ';
      default:
        return '';
    }
  }

  /// 利用可能なリフレクション頻度の選択肢を取得（DBから動的取得）
  static Future<List<String>> getAvailableFrequencies() async {
    try {
      final reflectionTypes = await _repository.getAllReflectionTypes();
      return reflectionTypes.map((type) => type.reflectionTypeName).toList();
    } catch (e) {
      // エラー時はデフォルト値を返す
      return ['週に1回', '2週に1回', '月に1回'];
    }
  }

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
