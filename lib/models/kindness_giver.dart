class KindnessGiver {
  final String name;
  final String category;
  final String gender;
  final String? avatarUrl;

  KindnessGiver({
    required this.name,
    required this.category,
    required this.gender,
    this.avatarUrl,
  });
}
