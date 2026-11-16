class ProviderModel {
  final String userId;
  final String name;
  final String photoUrl;
  final String? phoneEn;
  final List<String> skillNames;
  final String verificationLevel;
  final double averageRating;
  final double distanceKm;
  final double workingRadiusKm;
  final bool hasSmartphone;
  final bool isAvailable;
  final double latitude;
  final double longitude;
  final String? lastActiveAt;
  final int? costRangeMin;
  final int? costRangeMax;

  bool get hasCostRange => costRangeMin != null && costRangeMax != null;

  ProviderModel({
    required this.userId,
    required this.name,
    required this.photoUrl,
    this.phoneEn,
    required this.skillNames,
    required this.verificationLevel,
    required this.averageRating,
    required this.distanceKm,
    required this.workingRadiusKm,
    required this.hasSmartphone,
    required this.isAvailable,
    required this.latitude,
    required this.longitude,
    this.lastActiveAt,
    this.costRangeMin,
    this.costRangeMax,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      userId: json['user_id'] ?? '',
      name: json['name'] ?? '',
      photoUrl: json['photo_url'] ?? '',
      phoneEn: json['phone_en'],
      skillNames: json['skill_names'] != null 
          ? List<String>.from(json['skill_names'])
          : (json['skill_name'] != null ? [json['skill_name'].toString()] : []),
      verificationLevel: json['verification_level'] ?? '',
      averageRating: (json['average_rating'] ?? 0).toDouble(),
      distanceKm: (json['distance_km'] ?? 0).toDouble(),
      workingRadiusKm: (json['working_radius_km'] ?? 0).toDouble(),
      hasSmartphone: json['has_smartphone'] ?? false,
      isAvailable: json['is_available'] ?? false,
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      lastActiveAt: json['last_active_at']?.toString(),
      costRangeMin: json['cost_range_min'] is num
          ? (json['cost_range_min'] as num).toInt()
          : int.tryParse(json['cost_range_min']?.toString() ?? ''),
      costRangeMax: json['cost_range_max'] is num
          ? (json['cost_range_max'] as num).toInt()
          : int.tryParse(json['cost_range_max']?.toString() ?? ''),
    );
  }
}
