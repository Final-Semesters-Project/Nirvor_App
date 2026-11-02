class UrgentBroadcastDetailModel {
  final String broadcastId;
  final String status;
  final int skillId;
  final String skillName;
  final DateTime expiresAt;
  final double seekerLatitude;
  final double seekerLongitude;

  UrgentBroadcastDetailModel({
    required this.broadcastId,
    required this.status,
    required this.skillId,
    required this.skillName,
    required this.expiresAt,
    required this.seekerLatitude,
    required this.seekerLongitude,
  });

  bool get isExpired =>
      status.toLowerCase() == 'expired' ||
      DateTime.now().isAfter(expiresAt);

  bool get isClaimed => status.toLowerCase() == 'claimed';
  bool get isBroadcasting => status.toLowerCase() == 'broadcasting';

  factory UrgentBroadcastDetailModel.fromJson(Map<String, dynamic> json) {
    return UrgentBroadcastDetailModel(
      broadcastId: json['broadcast_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'broadcasting',
      skillId: json['skill_id'] is int ? json['skill_id'] : 0,
      skillName: json['skill_name']?.toString() ?? 'Service',
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString()) ??
              DateTime.now().add(const Duration(minutes: 5))
          : DateTime.now().add(const Duration(minutes: 5)),
      seekerLatitude: (json['seeker_latitude'] as num?)?.toDouble() ?? 0.0,
      seekerLongitude: (json['seeker_longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

