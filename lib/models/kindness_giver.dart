class KindnessGiver {
  final String name;
  final String relationship;
  final String gender;
  final String? avatarUrl;

  KindnessGiver({
    required this.name,
    required this.relationship,
    required this.gender,
    this.avatarUrl,
  });
}
