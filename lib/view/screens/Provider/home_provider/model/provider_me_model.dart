class ProviderMeModel {
  final String userId;
  final String role;
  final String phone;
  final String name;
  final bool isActive;
  final String verificationLevel; // "basic" | "verified" | "trusted"
  final String verificationStatus; // "not_initiated" | "pending" | "approved" | "rejected"
  final String? verificationRejectionReason;
  final String? baseAddress;
  final int? workingRadiusKm;
  final bool hasSmartphone;
  final bool isAvailable;
  final double? averageRating;
  final String? photoUrl;
  final String? nidUrlFront;
  final String? nidUrlBack;
  final bool warningStatus;
  final String? aiReviewSummary;
  final String? createdAt;

  ProviderMeModel({
    required this.userId,
    required this.role,
    required this.phone,
    required this.name,
    required this.isActive,
    required this.verificationLevel,
    required this.verificationStatus,
    this.verificationRejectionReason,
    this.baseAddress,
    this.workingRadiusKm,
    this.hasSmartphone = true,
    this.isAvailable = true,
    this.averageRating,
    this.photoUrl,
    this.nidUrlFront,
    this.nidUrlBack,
    this.warningStatus = false,
    this.aiReviewSummary,
    this.createdAt,
  });

  factory ProviderMeModel.fromJson(Map<String, dynamic> json) {
    return ProviderMeModel(
      userId: json['user_id']?.toString() ?? '',
      role: json['role']?.toString() ?? 'provider',
      phone: json['phone']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      isActive: json['is_active'] == true,
      verificationLevel:
          json['verification_level']?.toString().toLowerCase() ?? 'basic',
      verificationStatus:
          json['verification_status']?.toString().toLowerCase() ??
              'not_initiated',
      verificationRejectionReason:
          json['verification_rejection_reason']?.toString(),
      baseAddress: json['base_address']?.toString(),
      workingRadiusKm: json['working_radius_km'] != null
          ? int.tryParse(json['working_radius_km'].toString())
          : null,
      hasSmartphone: json['has_smartphone'] == true,
      isAvailable: json['is_available'] == true,
      averageRating: json['average_rating'] != null
          ? double.tryParse(json['average_rating'].toString())
          : null,
      photoUrl: json['photo_url']?.toString(),
      nidUrlFront: json['nid_url_front']?.toString(),
      nidUrlBack: json['nid_url_back']?.toString(),
      warningStatus: json['warning_status'] == true,
      aiReviewSummary: json['ai_review_summary']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

