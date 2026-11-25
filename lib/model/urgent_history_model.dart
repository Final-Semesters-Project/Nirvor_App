class SeekerUrgentBroadcastItemModel {
  final String broadcastId;
  final String status;
  final int skillId;
  final String skillName;
  final DateTime createdAt;
  final DateTime expiresAt;
  final int? secondsRemaining;
  final DateTime? cancelledAt;
  final String? providerName;
  final String? providerPhone;

  SeekerUrgentBroadcastItemModel({
    required this.broadcastId,
    required this.status,
    required this.skillId,
    required this.skillName,
    required this.createdAt,
    required this.expiresAt,
    this.secondsRemaining,
    this.cancelledAt,
    this.providerName,
    this.providerPhone,
  });

  bool get isBroadcasting => status.toLowerCase() == 'broadcasting';
  bool get isClaimed => status.toLowerCase() == 'claimed';
  bool get isCancelled =>
      status.toLowerCase() == 'cancelled' || status.toLowerCase() == 'cancel';
  bool get isExpired => status.toLowerCase() == 'expired';

  factory SeekerUrgentBroadcastItemModel.fromJson(Map<String, dynamic> json) {
    return SeekerUrgentBroadcastItemModel(
      broadcastId: (json['broadcast_id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      skillId: json['skill_id'] is int
          ? json['skill_id']
          : int.tryParse(json['skill_id']?.toString() ?? '0') ?? 0,
      skillName: (json['skill_name'] ?? '').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      secondsRemaining: json['seconds_remaining'] as int?,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.tryParse(json['cancelled_at'].toString())
          : null,
      providerName: json['provider_name']?.toString(),
      providerPhone: json['provider_phone']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'broadcast_id': broadcastId,
        'status': status,
        'skill_id': skillId,
        'skill_name': skillName,
        'created_at': createdAt.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'seconds_remaining': secondsRemaining,
        'cancelled_at': cancelledAt?.toIso8601String(),
        'provider_name': providerName,
        'provider_phone': providerPhone,
      };
}

class ProviderUrgentBroadcastItemModel {
  final String broadcastId;
  final String status;
  final int skillId;
  final String skillName;
  final DateTime createdAt;
  final DateTime? cancelledAt;
  final String seekerName;
  final String? seekerPhone;
  final double? seekerLatitude;
  final double? seekerLongitude;

  ProviderUrgentBroadcastItemModel({
    required this.broadcastId,
    required this.status,
    required this.skillId,
    required this.skillName,
    required this.createdAt,
    this.cancelledAt,
    required this.seekerName,
    this.seekerPhone,
    this.seekerLatitude,
    this.seekerLongitude,
  });

  bool get isClaimed => status.toLowerCase() == 'claimed';
  bool get isCancelled =>
      status.toLowerCase() == 'cancelled' || status.toLowerCase() == 'cancel';
  bool get isExpired => status.toLowerCase() == 'expired';

  factory ProviderUrgentBroadcastItemModel.fromJson(Map<String, dynamic> json) {
    return ProviderUrgentBroadcastItemModel(
      broadcastId: (json['broadcast_id'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      skillId: json['skill_id'] is int
          ? json['skill_id']
          : int.tryParse(json['skill_id']?.toString() ?? '0') ?? 0,
      skillName: (json['skill_name'] ?? '').toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.tryParse(json['cancelled_at'].toString())
          : null,
      seekerName: (json['seeker_name'] ?? '').toString(),
      seekerPhone: json['seeker_phone']?.toString(),
      seekerLatitude: json['seeker_latitude'] != null
          ? double.tryParse(json['seeker_latitude'].toString())
          : null,
      seekerLongitude: json['seeker_longitude'] != null
          ? double.tryParse(json['seeker_longitude'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'broadcast_id': broadcastId,
        'status': status,
        'skill_id': skillId,
        'skill_name': skillName,
        'created_at': createdAt.toIso8601String(),
        'cancelled_at': cancelledAt?.toIso8601String(),
        'seeker_name': seekerName,
        'seeker_phone': seekerPhone,
        'seeker_latitude': seekerLatitude,
        'seeker_longitude': seekerLongitude,
      };
}
