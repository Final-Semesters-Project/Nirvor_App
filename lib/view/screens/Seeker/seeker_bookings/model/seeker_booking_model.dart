class BookingItemModel {
  final String bookingId;
  final String status;
  final int skillId;
  final String skillName;
  final DateTime createdAt;
  final DateTime? workSchedule;
  final String otherPartyName;
  final String? otherPartyPhone;
  final String? providerId;

  BookingItemModel({
    required this.bookingId,
    required this.status,
    required this.skillId,
    required this.skillName,
    required this.createdAt,
    this.workSchedule,
    required this.otherPartyName,
    this.otherPartyPhone,
    this.providerId,
  });

  bool get isActive =>
      status.toLowerCase() == 'initiated' ||
      status.toLowerCase() == 'in_progress';

  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isInitiated => status.toLowerCase() == 'initiated';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isCancelled =>
      status.toLowerCase() == 'cancelled' ||
      status.toLowerCase() == 'auto_expired';

  factory BookingItemModel.fromJson(Map<String, dynamic> json) {
    return BookingItemModel(
      bookingId: json['booking_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'initiated',
      skillId: json['skill_id'] is int ? json['skill_id'] : 0,
      skillName: json['skill_name']?.toString() ?? 'Service',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      workSchedule: json['work_schedule'] != null
          ? DateTime.tryParse(json['work_schedule'].toString())
          : null,
      otherPartyName: json['other_party_name']?.toString() ?? 'Provider',
      otherPartyPhone: json['other_party_phone']?.toString(),
      providerId: json['provider_id']?.toString() ??
          json['provider']?['id']?.toString() ??
          json['other_party_id']?.toString(),
    );
  }
}

class BookingDetailModel {
  final String bookingId;
  final String status;
  final int skillId;
  final DateTime createdAt;
  final DateTime? callUnlockedAt;
  final DateTime? confirmedAt;
  final DateTime? workSchedule;
  final DateTime? completedAt;
  final String otherPartyName;
  final String? otherPartyPhone;
  final double? jobLatitude;
  final double? jobLongitude;
  final String? providerId;
  final bool? hasReviewed;

  BookingDetailModel({
    required this.bookingId,
    required this.status,
    required this.skillId,
    required this.createdAt,
    this.callUnlockedAt,
    this.confirmedAt,
    this.workSchedule,
    this.completedAt,
    required this.otherPartyName,
    this.otherPartyPhone,
    this.jobLatitude,
    this.jobLongitude,
    this.providerId,
    this.hasReviewed,
  });

  bool get isInProgress => status.toLowerCase() == 'in_progress';
  bool get isInitiated => status.toLowerCase() == 'initiated';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isCancelled =>
      status.toLowerCase() == 'cancelled' ||
      status.toLowerCase() == 'auto_expired';

  factory BookingDetailModel.fromJson(Map<String, dynamic> json) {
    return BookingDetailModel(
      bookingId: json['booking_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'initiated',
      skillId: json['skill_id'] is int ? json['skill_id'] : 0,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      callUnlockedAt: json['call_unlocked_at'] != null
          ? DateTime.tryParse(json['call_unlocked_at'].toString())
          : null,
      confirmedAt: json['confirmed_at'] != null
          ? DateTime.tryParse(json['confirmed_at'].toString())
          : null,
      workSchedule: json['work_schedule'] != null
          ? DateTime.tryParse(json['work_schedule'].toString())
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'].toString())
          : null,
      otherPartyName: json['other_party_name']?.toString() ?? 'Provider',
      otherPartyPhone: json['other_party_phone']?.toString(),
      jobLatitude: json['job_latitude'] != null
          ? double.tryParse(json['job_latitude'].toString())
          : null,
      jobLongitude: json['job_longitude'] != null
          ? double.tryParse(json['job_longitude'].toString())
          : null,
      providerId: json['provider_id']?.toString() ??
          json['provider']?['id']?.toString() ??
          json['other_party_id']?.toString(),
      hasReviewed: json['has_reviewed'] == true ||
          json['is_reviewed'] == true ||
          json['reviewed'] == true,
    );
  }

  BookingDetailModel copyWith({
    bool? hasReviewed,
    String? status,
    DateTime? completedAt,
  }) {
    return BookingDetailModel(
      bookingId: bookingId,
      status: status ?? this.status,
      skillId: skillId,
      createdAt: createdAt,
      callUnlockedAt: callUnlockedAt,
      confirmedAt: confirmedAt,
      workSchedule: workSchedule,
      completedAt: completedAt ?? this.completedAt,
      otherPartyName: otherPartyName,
      otherPartyPhone: otherPartyPhone,
      jobLatitude: jobLatitude,
      jobLongitude: jobLongitude,
      providerId: providerId,
      hasReviewed: hasReviewed ?? this.hasReviewed,
    );
  }
}

class PublicProviderSkill {
  final int id;
  final String name;

  PublicProviderSkill({required this.id, required this.name});

  factory PublicProviderSkill.fromJson(Map<String, dynamic> json) {
    return PublicProviderSkill(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }
}

class PublicProviderModel {
  final String userId;
  final String name;
  final String? photoUrl;
  final String verificationLevel;
  final double averageRating;
  final int workingRadiusKm;
  final bool hasSmartphone;
  final bool isAvailable;
  final String? aiReviewSummary;
  final List<PublicProviderSkill> skills;
  final DateTime? lastActiveAt;

  PublicProviderModel({
    required this.userId,
    required this.name,
    this.photoUrl,
    required this.verificationLevel,
    required this.averageRating,
    required this.workingRadiusKm,
    required this.hasSmartphone,
    required this.isAvailable,
    this.aiReviewSummary,
    required this.skills,
    this.lastActiveAt,
  });

  bool get isVerified =>
      verificationLevel.toLowerCase() == 'verified' ||
      verificationLevel.toLowerCase() == 'nid';

  factory PublicProviderModel.fromJson(Map<String, dynamic> json) {
    List rawSkills = json['skills'] is List ? json['skills'] : [];
    return PublicProviderModel(
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString(),
      verificationLevel: json['verification_level']?.toString() ?? 'basic',
      averageRating: (json['average_rating'] is num)
          ? (json['average_rating'] as num).toDouble()
          : double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0.0,
      workingRadiusKm: json['working_radius_km'] is int
          ? json['working_radius_km']
          : int.tryParse(json['working_radius_km']?.toString() ?? '0') ?? 0,
      hasSmartphone: json['has_smartphone'] ?? false,
      isAvailable: json['is_available'] ?? true,
      aiReviewSummary: json['ai_review_summary']?.toString(),
      skills: rawSkills.map((e) => PublicProviderSkill.fromJson(e)).toList(),
      lastActiveAt: json['last_active_at'] != null
          ? DateTime.tryParse(json['last_active_at'].toString())
          : null,
    );
  }
}
