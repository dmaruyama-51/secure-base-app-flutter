class Member {
  final String name;
  final String category;
  final String gender;
  final String? avatarUrl;

  Member({
    required this.name,
    required this.category,
    required this.gender,
    this.avatarUrl,
  });
}
