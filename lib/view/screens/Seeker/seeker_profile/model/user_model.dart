class UserModel {
  final String userId;
  final String role;
  final String phone;
  final String name;
  final bool isActive;
  final String createdAt;
  final String photoUrl;
  final String homeAddress;
  final double? homeLatitude;
  final double? homeLongitude;

  UserModel({
    required this.userId,
    required this.role,
    required this.phone,
    required this.name,
    required this.isActive,
    required this.createdAt,
    this.photoUrl = '',
    this.homeAddress = '',
    this.homeLatitude,
    this.homeLongitude,
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
      homeAddress: json['home_address'] ?? '',
      homeLatitude: json['home_latitude'] != null
          ? double.tryParse(json['home_latitude'].toString())
          : null,
      homeLongitude: json['home_longitude'] != null
          ? double.tryParse(json['home_longitude'].toString())
          : null,
    );
  }
}
