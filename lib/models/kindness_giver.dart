class KindnessGiver {
  final int? id;
  final String name;
  final String category;
  final String gender;
  final String? avatarUrl;

  KindnessGiver({
    this.id,
    required this.name,
    required this.category,
    required this.gender,
    this.avatarUrl,
  });
}
