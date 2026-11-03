import 'package:intl/intl.dart';

class ReviewItemModel {
  final String reviewId;
  final String reviewerName;
  final int rating;
  final String? comment;
  final bool isAnonymous;
  final DateTime createdAt;

  ReviewItemModel({
    required this.reviewId,
    required this.reviewerName,
    required this.rating,
    this.comment,
    required this.isAnonymous,
    required this.createdAt,
  });

  factory ReviewItemModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate = DateTime.now();
    if (json['created_at'] != null) {
      parsedDate = DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    }

    return ReviewItemModel(
      reviewId: json['review_id']?.toString() ?? '',
      reviewerName: json['reviewer_name']?.toString() ?? '',
      rating: json['rating'] is int
          ? json['rating']
          : int.tryParse(json['rating']?.toString() ?? '5') ?? 5,
      comment: json['comment']?.toString(),
      isAnonymous: json['is_anonymous'] == true,
      createdAt: parsedDate,
    );
  }

  String get formattedDateTime {
    return DateFormat('dd MMM yyyy, hh:mm a').format(createdAt.toLocal());
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

