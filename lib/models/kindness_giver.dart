class KindnessGiver {
  final int? id;
  final String userId;
  final String giverName;
  final int relationshipId;
  final int genderId;
  final DateTime? createdAt;
  final String? avatarUrl;

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
    this.relationshipName,
    this.genderName,
  });

  // 後方互換性のためのgetter（kindness_record用）
  String get name => giverName;
  String get category => relationshipName ?? '';
  String get gender => genderName ?? '';

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
      relationshipName: relationshipName ?? this.relationshipName,
      genderName: genderName ?? this.genderName,
    );
  }
}
