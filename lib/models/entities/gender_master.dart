class GenderMaster {
  final int id;
  final String name;
  final DateTime createdAt;

  GenderMaster({required this.id, required this.name, required this.createdAt});

  factory GenderMaster.fromJson(Map<String, dynamic> json) {
    return GenderMaster(
      id: json['id'] as int,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'created_at': createdAt.toIso8601String()};
  }
}
