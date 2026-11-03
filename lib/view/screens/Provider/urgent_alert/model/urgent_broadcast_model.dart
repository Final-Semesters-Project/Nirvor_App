import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Represents an ongoing/claimed urgent job for the provider
class ActiveUrgentJobModel {
  final String broadcastId;
  final String status;
  final String seekerName;
  final String seekerPhone;
  final String skillName;
  final double seekerLatitude;
  final double seekerLongitude;
  final double distanceKm;
  final DateTime claimedAt;

  ActiveUrgentJobModel({
    required this.broadcastId,
    required this.status,
    required this.seekerName,
    required this.seekerPhone,
    required this.skillName,
    required this.seekerLatitude,
    required this.seekerLongitude,
    required this.distanceKm,
    required this.claimedAt,
  });

  Map<String, dynamic> toJson() => {
        'broadcast_id': broadcastId,
        'status': status,
        'seeker_name': seekerName,
        'seeker_phone': seekerPhone,
        'skill_name': skillName,
        'seeker_latitude': seekerLatitude,
        'seeker_longitude': seekerLongitude,
        'distance_km': distanceKm,
        'claimed_at': claimedAt.toIso8601String(),
      };

  factory ActiveUrgentJobModel.fromJson(Map<String, dynamic> json) =>
      ActiveUrgentJobModel(
        broadcastId: json['broadcast_id']?.toString() ?? '',
        status: json['status']?.toString() ?? 'claimed',
        seekerName: json['seeker_name']?.toString() ?? 'Seeker',
        seekerPhone: json['seeker_phone']?.toString() ?? '',
        skillName: json['skill_name']?.toString() ?? 'Service',
        seekerLatitude: (json['seeker_latitude'] as num?)?.toDouble() ?? 0.0,
        seekerLongitude: (json['seeker_longitude'] as num?)?.toDouble() ?? 0.0,
        distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
        claimedAt: json['claimed_at'] != null
            ? DateTime.tryParse(json['claimed_at'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
}

// Storage helpers for active urgent job
const String _kActiveUrgentJobKey = 'active_urgent_job_data';

Future<void> saveActiveUrgentJob(ActiveUrgentJobModel job) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_kActiveUrgentJobKey, jsonEncode(job.toJson()));
}

Future<ActiveUrgentJobModel?> getActiveUrgentJob() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kActiveUrgentJobKey);
    if (raw != null && raw.isNotEmpty) {
      final Map<String, dynamic> map = jsonDecode(raw);
      return ActiveUrgentJobModel.fromJson(map);
    }
  } catch (e) {
    // Ignore parse error
  }
  return null;
}

Future<void> clearActiveUrgentJob() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_kActiveUrgentJobKey);
}
