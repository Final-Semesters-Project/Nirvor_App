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
      parsedDate =
          DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now();
    }

    final dynamic isAnonVal = json['is_anonymous'] ?? json['s_anonymous'];
    final bool isAnon = isAnonVal == true ||
        isAnonVal?.toString().toLowerCase() == 'true' ||
        isAnonVal == 1;

    return ReviewItemModel(
      reviewId: json['review_id']?.toString() ?? '',
      reviewerName: json['reviewer_name']?.toString() ?? '',
      rating: json['rating'] is int
          ? json['rating']
          : int.tryParse(json['rating']?.toString() ?? '5') ?? 5,
      comment: json['comment']?.toString(),
      isAnonymous: isAnon,
      createdAt: parsedDate,
    );
  }

  String getReviewerDisplayName(bool isBn) {
    if (isAnonymous) {
      return isBn ? 'নাম প্রকাশে অনিচ্ছুক গ্রাহক' : 'Anonymous Seeker';
    }
    if (reviewerName.trim().isNotEmpty) {
      return reviewerName.trim();
    }
    return isBn ? 'গ্রাহক' : 'Seeker';
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

  String localizedTimeAgo(bool isBn) {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final y = (difference.inDays / 365).floor();
      return isBn ? '$y বছর আগে' : '${y}y ago';
    } else if (difference.inDays > 30) {
      final m = (difference.inDays / 30).floor();
      return isBn ? '$m মাস আগে' : '${m}mo ago';
    } else if (difference.inDays > 0) {
      return isBn ? '${difference.inDays} দিন আগে' : '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return isBn ? '${difference.inHours} ঘণ্টা আগে' : '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return isBn ? '${difference.inMinutes} মিনিট আগে' : '${difference.inMinutes}m ago';
    } else {
      return isBn ? 'কিছুক্ষণ আগে' : 'Just now';
    }
  }
}

class ProviderReviewPaginatedModel {
  final List<ReviewItemModel> items;
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;

  ProviderReviewPaginatedModel({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
  });

  factory ProviderReviewPaginatedModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'];
    List<ReviewItemModel> list = [];
    if (rawItems is List) {
      list = rawItems
          .map((i) => ReviewItemModel.fromJson(i as Map<String, dynamic>))
          .toList();
    }
    return ProviderReviewPaginatedModel(
      items: list,
      total: json['total'] is int
          ? json['total']
          : int.tryParse(json['total']?.toString() ?? '0') ?? 0,
      page: json['page'] is int
          ? json['page']
          : int.tryParse(json['page']?.toString() ?? '1') ?? 1,
      pageSize: json['page_size'] is int
          ? json['page_size']
          : int.tryParse(json['page_size']?.toString() ?? '20') ?? 20,
      totalPages: json['total_pages'] is int
          ? json['total_pages']
          : int.tryParse(json['total_pages']?.toString() ?? '0') ?? 0,
      hasNext: json['has_next'] == true,
      hasPrev: json['has_prev'] == true,
    );
  }
}
