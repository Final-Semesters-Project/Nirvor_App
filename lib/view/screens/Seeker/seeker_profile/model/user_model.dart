class UserModel {
  final String userId;
  final String role;
  final String phone;
  final String name;
  final String? nameEn;
  final String? nameBn;
  final bool isActive;
  final String createdAt;
  final String preferredLang;
  final String photoUrl;
  final String? photoPublicId;
  final String homeAddress;
  final double? latitude;
  final double? longitude;

  // Compatibility getters for homeLatitude and homeLongitude
  double? get homeLatitude => latitude;
  double? get homeLongitude => longitude;

  UserModel({
    required this.userId,
    required this.role,
    required this.phone,
    required this.name,
    this.nameEn,
    this.nameBn,
    required this.isActive,
    required this.createdAt,
    this.preferredLang = 'en',
    this.photoUrl = '',
    this.photoPublicId,
    this.homeAddress = '',
    double? latitude,
    double? longitude,
    double? homeLatitude,
    double? homeLongitude,
  })  : latitude = latitude ?? homeLatitude,
        longitude = longitude ?? homeLongitude;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final double? lat = json['latitude'] != null
        ? double.tryParse(json['latitude'].toString())
        : (json['home_latitude'] != null
            ? double.tryParse(json['home_latitude'].toString())
            : null);

    final double? lng = json['longitude'] != null
        ? double.tryParse(json['longitude'].toString())
        : (json['home_longitude'] != null
            ? double.tryParse(json['home_longitude'].toString())
            : null);

    final String photo = json['photo_url']?.toString() ?? '';
    final String address = json['home_address']?.toString() ??
        json['base_address']?.toString() ??
        '';

    return UserModel(
      userId: json['user_id']?.toString() ?? '',
      role: json['role']?.toString() ?? 'seeker',
      phone: json['phone']?.toString() ?? '',
      nameEn: json['name_en']?.toString(),
      nameBn: json['name_bn']?.toString(),
      name: json['name']?.toString() ??
          (json['name_bn'] != null && json['name_bn'].toString().isNotEmpty
              ? json['name_bn'].toString()
              : json['name_en']?.toString() ?? ''),
      isActive: json['is_active'] == true,
      createdAt: json['created_at']?.toString() ?? '',
      preferredLang: json['preferred_lang']?.toString() ?? 'en',
      photoUrl: photo,
      photoPublicId: json['photo_public_id']?.toString(),
      homeAddress: address,
      latitude: lat,
      longitude: lng,
    );
  }
}

/// Typedef representing Swagger's #0 SeekerMeSchema
typedef SeekerMeModel = UserModel;
