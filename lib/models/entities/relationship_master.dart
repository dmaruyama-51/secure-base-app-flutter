class RelationshipMaster {
  final int id;
  final String name;
  final DateTime createdAt;

  RelationshipMaster({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory RelationshipMaster.fromJson(Map<String, dynamic> json) {
    return RelationshipMaster(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'created_at': createdAt.toIso8601String()};
  }
}
