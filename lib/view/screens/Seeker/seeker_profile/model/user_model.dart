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
      userId: json['user_id']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      name: json['name']?.toString() ?? json['name_en']?.toString() ?? '',
      isActive: json['is_active'] == true,
      createdAt: json['created_at']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString() ?? '',
      homeAddress: json['home_address']?.toString() ??
          json['base_address']?.toString() ??
          '',
      homeLatitude: json['home_latitude'] != null
          ? double.tryParse(json['home_latitude'].toString())
          : (json['latitude'] != null
              ? double.tryParse(json['latitude'].toString())
              : null),
      homeLongitude: json['home_longitude'] != null
          ? double.tryParse(json['home_longitude'].toString())
          : (json['longitude'] != null
              ? double.tryParse(json['longitude'].toString())
              : null),
    );
  }
}
