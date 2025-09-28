// Project imports:
import 'repositories/kindness_giver_repository.dart';
import 'repositories/kindness_record_repository.dart';

class KindnessGiver {
  final int? id;
  final String userId;
  final String giverName;
  final int relationshipId;
  final int genderId;
  final DateTime? createdAt;
  final String? avatarUrl;
  final bool isArchived;

  // UI表示用のプロパティ（JOINしたデータから取得）
  final String? relationshipName;
  final String? genderName;

  KindnessGiver({
    this.id,
    required this.userId,
    required this.giverName,
    required this.relationshipId,
    required this.genderId,
    this.createdAt,
    this.avatarUrl,
    this.isArchived = false,
    this.relationshipName,
    this.genderName,
  });

  factory KindnessGiver.fromJson(Map<String, dynamic> json) {
    return KindnessGiver(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      giverName: json['giver_name'] as String,
      relationshipId: json['relationship_id'] as int,
      genderId: json['gender_id'] as int,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      avatarUrl: json['avatar_url'] as String?,
      isArchived: json['is_archived'] as bool? ?? false,
      relationshipName: json['relationship_name'] as String?,
      genderName: json['gender_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'giver_name': giverName,
      'relationship_id': relationshipId,
      'gender_id': genderId,
      'created_at': createdAt?.toIso8601String(),
      'avatar_url': avatarUrl,
      'is_archived': isArchived,
    };
  }

  // 新規作成用のコンストラクタ（IDなし）
  KindnessGiver.create({
    required this.userId,
    required this.giverName,
    required this.relationshipId,
    required this.genderId,
    this.avatarUrl,
  }) : id = null,
       createdAt = null,
       isArchived = false,
       relationshipName = null,
       genderName = null;

  // コピー用のメソッド
  KindnessGiver copyWith({
    int? id,
    String? userId,
    String? giverName,
    int? relationshipId,
    int? genderId,
    DateTime? createdAt,
    String? avatarUrl,
    bool? isArchived,
    String? relationshipName,
    String? genderName,
  }) {
    return KindnessGiver(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      giverName: giverName ?? this.giverName,
      relationshipId: relationshipId ?? this.relationshipId,
      genderId: genderId ?? this.genderId,
      createdAt: createdAt ?? this.createdAt,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      isArchived: isArchived ?? this.isArchived,
      relationshipName: relationshipName ?? this.relationshipName,
      genderName: genderName ?? this.genderName,
    );
  }

  // ===== ビジネスロジック（静的メソッド） =====

  /// メンバー新規作成
  static Future<KindnessGiver> createKindnessGiver({
    required String giverName,
    required String genderName,
    required String relationshipName,
    KindnessGiverRepository? repository,
  }) async {
    final repo = repository ?? KindnessGiverRepository();

    // マスターデータからIDを取得
    final genderId = await repo.getGenderIdByName(genderName);
    final relationshipId = await repo.getRelationshipIdByName(relationshipName);

    if (genderId == null) {
      throw Exception('選択された性別が見つかりません: $genderName');
    }
    if (relationshipId == null) {
      throw Exception('選択された関係性が見つかりません: $relationshipName');
    }

    // エンティティ作成
    final kindnessGiver = KindnessGiver.create(
      userId: '', // Repository内で現在のユーザーIDを設定
      giverName: giverName.trim(),
      relationshipId: relationshipId,
      genderId: genderId,
    );

    // 保存
    final createdGiver = await repo.createKindnessGiver(kindnessGiver);

    if (createdGiver.id == null) {
      throw Exception('やさしさをくれる人の保存に失敗しました');
    }

    return createdGiver;
  }

  /// メンバー情報更新
  static Future<KindnessGiver> updateKindnessGiver({
    required KindnessGiver originalKindnessGiver,
    required String giverName,
    required String genderName,
    required String relationshipName,
    KindnessGiverRepository? repository,
  }) async {
    final repo = repository ?? KindnessGiverRepository();

    // マスターデータからIDを取得
    final genderId = await repo.getGenderIdByName(genderName);
    final relationshipId = await repo.getRelationshipIdByName(relationshipName);

    if (genderId == null) {
      throw Exception('選択された性別が見つかりません: $genderName');
    }
    if (relationshipId == null) {
      throw Exception('選択された関係性が見つかりません: $relationshipName');
    }

    // エンティティ更新
    final updatedKindnessGiver = originalKindnessGiver.copyWith(
      giverName: giverName.trim(),
      genderId: genderId,
      relationshipId: relationshipId,
    );

    // 保存
    await repo.updateKindnessGiver(updatedKindnessGiver);

    return updatedKindnessGiver;
  }

  /// メンバー一覧取得（アクティブのみ）
  static Future<List<KindnessGiver>> fetchKindnessGivers({
    KindnessGiverRepository? repository,
  }) async {
    final repo = repository ?? KindnessGiverRepository();
    try {
      return await repo.fetchKindnessGivers(includeArchived: false);
    } catch (e) {
      throw Exception('やさしさをくれる人の一覧取得に失敗しました: $e');
    }
  }

  /// アクティブなメンバー一覧を取得
  static Future<List<KindnessGiver>> fetchActiveKindnessGivers({
    KindnessGiverRepository? repository,
  }) async {
    final repo = repository ?? KindnessGiverRepository();
    try {
      return await repo.fetchKindnessGivers(includeArchived: false);
    } catch (e) {
      throw Exception('やさしさをくれる人の一覧取得に失敗しました: $e');
    }
  }

  /// アーカイブされたメンバー一覧を取得
  static Future<List<KindnessGiver>> fetchArchivedKindnessGivers({
    KindnessGiverRepository? repository,
  }) async {
    final repo = repository ?? KindnessGiverRepository();
    try {
      return await repo.fetchArchivedKindnessGivers();
    } catch (e) {
      throw Exception('アーカイブされたメンバー一覧の取得に失敗しました: $e');
    }
  }

  /// 全メンバー一覧を取得（アクティブ+アーカイブ）
  static Future<List<KindnessGiver>> fetchAllKindnessGivers({
    KindnessGiverRepository? repository,
  }) async {
    final repo = repository ?? KindnessGiverRepository();
    try {
      return await repo.fetchKindnessGivers(includeArchived: true);
    } catch (e) {
      throw Exception('全メンバー一覧の取得に失敗しました: $e');
    }
  }

  /// メンバーをアーカイブする
  static Future<void> archiveKindnessGiver(
    int id, {
    KindnessGiverRepository? repository,
  }) async {
    final repo = repository ?? KindnessGiverRepository();
    try {
      final success = await repo.archiveKindnessGiver(id);
      if (!success) {
        throw Exception('アーカイブ処理が失敗しました');
      }
    } catch (e) {
      throw Exception('やさしさをくれる人のアーカイブに失敗しました: $e');
    }
  }

  /// メンバーのアーカイブを解除する
  static Future<void> unarchiveKindnessGiver(
    int id, {
    KindnessGiverRepository? repository,
  }) async {
    final repo = repository ?? KindnessGiverRepository();
    try {
      final success = await repo.unarchiveKindnessGiver(id);
      if (!success) {
        throw Exception('アーカイブ解除処理が失敗しました');
      }
    } catch (e) {
      throw Exception('やさしさをくれる人のアーカイブ解除に失敗しました: $e');
    }
  }

  /// メンバーに関連する優しさ記録の件数を取得
  static Future<int> getKindnessRecordCount(
    int id, {
    KindnessGiverRepository? repository,
  }) async {
    final repo = repository ?? KindnessGiverRepository();
    try {
      return await repo.getKindnessRecordCount(id);
    } catch (e) {
      print('優しさ記録件数取得エラー: $e');
      return 0;
    }
  }

  /// メンバー削除
  static Future<void> deleteKindnessGiver(
    int id, {
    KindnessGiverRepository? repository,
  }) async {
    final repo = repository ?? KindnessGiverRepository();
    try {
      final success = await repo.deleteKindnessGiver(id);
      if (!success) {
        throw Exception('削除処理が失敗しました');
      }
    } catch (e) {
      // エラーメッセージをそのまま再スロー
      rethrow;
    }
  }

  /// 特定のメンバーの統計情報を取得
  static Future<Map<String, dynamic>> fetchKindnessGiverStatistics(
    int giverId, {
    KindnessRecordRepository? repository,
  }) async {
    final repo = repository ?? KindnessRecordRepository();
    try {
      return await repo.fetchKindnessGiverStatistics(giverId);
    } catch (e) {
      // エラーが発生した場合は空の統計を返す
      return {
        'totalCount': 0,
        'receivedCount': 0,
        'givenCount': 0,
        'lastRecordDate': null,
        'recentCount': 0,
      };
    }
  }
}
