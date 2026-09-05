class UserModel {
  final String userId;
  final String role;
  final String phone;
  final String name;
  final bool isActive;
  final String createdAt;
  final String photoUrl;

  UserModel({
    required this.userId,
    required this.role,
    required this.phone,
    required this.name,
    required this.isActive,
    required this.createdAt,
    this.photoUrl = '',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'] ?? '',
      name: json['name'] ?? json['name_en'] ?? '',
      isActive: json['is_active'] ?? false,
      createdAt: json['created_at'] ?? '',
      photoUrl: json['photo_url'] ?? '',
    );
  }
}
