class KindnessGiver {
  final int? id;
  final String userId;
  final String name;
  final int relationshipId;
  final String relationship;
  final int genderId;
  final String gender;
  final String? avatarUrl;
  final DateTime? createdAt;

  KindnessGiver({
    this.id,
    required this.userId,
    required this.name,
    required this.relationshipId,
    required this.relationship,
    required this.genderId,
    required this.gender,
    this.avatarUrl,
    this.createdAt,
  });

  factory KindnessGiver.fromMap(
    Map<String, dynamic> map, {
    required String relationshipName,
    required String genderName,
  }) {
    return KindnessGiver(
      id: map['id'] ?? 0,
      userId: map['user_id'] ?? '',
      name: map['giver_name'] ?? '',
      relationshipId: map['relationship_id'] ?? 0,
      relationship: relationshipName,
      genderId: map['gender_id'] ?? 0,
      gender: genderName,
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'user_id': userId,
      'giver_name': name,
      'relationship_id': relationshipId,
      'gender_id': genderId,
    };

    if (id != null) {
      map['id'] = id as Object;
    }

    return map;
  }
}
