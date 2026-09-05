class SkillModel {
  final int id;
  final String name;
  final int categoryId;

  SkillModel({required this.id, required this.name, required this.categoryId});

  factory SkillModel.fromJson(Map<String, dynamic> json) {
    return SkillModel(
      id: json['id'],
      name: json['name'] ?? '',
      categoryId: json['category_id'] ?? 0,
    );
  }
}
