class ReflectionTypeMaster {
  final int id;
  final String reflectionTypeName;
  final int reflectionPeriod;
  final DateTime createdAt;

  ReflectionTypeMaster({
    required this.id,
    required this.reflectionTypeName,
    required this.reflectionPeriod,
    required this.createdAt,
  });

  factory ReflectionTypeMaster.fromJson(Map<String, dynamic> json) {
    return ReflectionTypeMaster(
      id: json['id'] as int,
      reflectionTypeName: json['reflection_type_name'] as String,
      reflectionPeriod: json['reflection_period'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reflection_type_name': reflectionTypeName,
      'reflection_period': reflectionPeriod,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
