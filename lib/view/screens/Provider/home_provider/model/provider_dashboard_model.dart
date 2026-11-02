class ProviderDashboardSkill {
  final int id;
  final String name;

  ProviderDashboardSkill({
    required this.id,
    required this.name,
  });

  factory ProviderDashboardSkill.fromJson(Map<String, dynamic> json) {
    return ProviderDashboardSkill(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      };
}

class ProviderDashboardModel {
  final String userId;
  final String name;
  final String? photoUrl;
  final bool isAvailable;
  final String verificationLevel;
  final double? averageRating;
  final int? totalJobsDone;
  final String? aiReviewSummary;
  final int? workingRadiusKm;
  final List<ProviderDashboardSkill> skills;

  ProviderDashboardModel({
    required this.userId,
    required this.name,
    this.photoUrl,
    required this.isAvailable,
    required this.verificationLevel,
    this.averageRating,
    this.totalJobsDone,
    this.aiReviewSummary,
    this.workingRadiusKm,
    required this.skills,
  });

  factory ProviderDashboardModel.fromJson(Map<String, dynamic> json) {
    var rawSkills = json['skills'];
    List<ProviderDashboardSkill> parsedSkills = [];
    if (rawSkills is List) {
      parsedSkills = rawSkills
          .map((item) =>
              ProviderDashboardSkill.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    return ProviderDashboardModel(
      userId: json['user_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString(),
      isAvailable: json['is_available'] == true,
      verificationLevel: json['verification_level']?.toString() ?? 'basic',
      averageRating: json['average_rating'] != null
          ? (json['average_rating'] is num
              ? (json['average_rating'] as num).toDouble()
              : double.tryParse(json['average_rating'].toString()))
          : null,
      totalJobsDone: json['total_jobs_done'] != null
          ? (json['total_jobs_done'] is int
              ? json['total_jobs_done'] as int
              : int.tryParse(json['total_jobs_done'].toString()))
          : null,
      aiReviewSummary: json['ai_review_summary']?.toString(),
      workingRadiusKm: json['working_radius_km'] != null
          ? (json['working_radius_km'] is int
              ? json['working_radius_km'] as int
              : int.tryParse(json['working_radius_km'].toString()))
          : null,
      skills: parsedSkills,
    );
  }
}

