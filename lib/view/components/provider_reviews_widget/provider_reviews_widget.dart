import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../model/review_model.dart';
import '../../../../service/api_client.dart';
import '../../../../service/api_url.dart';
import '../../../../utils/app_colors/app_colors.dart';

class ProviderReviewsWidget extends StatefulWidget {
  final String providerId;
  final bool showHeader;
  final EdgeInsetsGeometry? margin;

  /// Global signal to notify all mounted ProviderReviewsWidgets to reload reviews
  static final RxInt refreshSignal = 0.obs;
  static String? _targetProviderId;

  /// Trigger a live refresh on mounted review widgets
  static void triggerRefresh([String? providerId]) {
    _targetProviderId = providerId;
    refreshSignal.value++;
  }

  const ProviderReviewsWidget({
    super.key,
    required this.providerId,
    this.showHeader = true,
    this.margin,
  });

  @override
  State<ProviderReviewsWidget> createState() => ProviderReviewsWidgetState();
}

class ProviderReviewsWidgetState extends State<ProviderReviewsWidget> {
  bool _isLoading = true;
  List<ReviewItemModel> _reviews = [];
  int _total = 0;
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasNext = false;
  bool _isLoadingMore = false;
  static const int _pageSize = 10;
  final Set<String> _expandedReviewIds = {};
  StreamSubscription? _refreshSub;

  String _toBnDigits(int number) {
    const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return number.toString().split('').map((char) {
      int? idx = int.tryParse(char);
      return idx != null ? bnDigits[idx] : char;
    }).join();
  }

  @override
  void initState() {
    super.initState();
    fetchReviews();
    _refreshSub = ProviderReviewsWidget.refreshSignal.listen((_) {
      if (mounted) {
        if (ProviderReviewsWidget._targetProviderId == null ||
            ProviderReviewsWidget._targetProviderId == widget.providerId) {
          fetchReviews(showLoadingIndicator: false);
        }
      }
    });
  }

  @override
  void dispose() {
    _refreshSub?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ProviderReviewsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.providerId != widget.providerId && widget.providerId.isNotEmpty) {
      fetchReviews();
    }
  }

  Future<void> fetchReviews({bool showLoadingIndicator = true}) async {
    if (widget.providerId.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (showLoadingIndicator && _reviews.isEmpty && mounted) {
      setState(() => _isLoading = true);
    }

    try {
      _currentPage = 1;
      final response = await ApiClient.getData(
        ApiUrl.providerReviews(widget.providerId, page: 1, pageSize: _pageSize),
      );

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;
        final List items = data['items'] ?? [];
        if (mounted) {
          setState(() {
            _reviews = items.map((e) => ReviewItemModel.fromJson(e)).toList();
            _total = data['total'] ?? _reviews.length;
            _currentPage = data['page'] ?? 1;
            _totalPages = data['total_pages'] ?? 1;
            _hasNext = data['has_next'] ?? (_reviews.length < _total);
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _reviews = [];
            _total = 0;
            _hasNext = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching provider reviews: $e");
      if (mounted) {
        setState(() {
          _reviews = [];
          _total = 0;
          _hasNext = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> loadMoreReviews() async {
    if (_isLoadingMore || !_hasNext || widget.providerId.isEmpty) return;

    setState(() => _isLoadingMore = true);

    try {
      final nextPage = _currentPage + 1;
      final response = await ApiClient.getData(
        ApiUrl.providerReviews(widget.providerId, page: nextPage, pageSize: _pageSize),
      );

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;
        final List items = data['items'] ?? [];
        final newReviews = items.map((e) => ReviewItemModel.fromJson(e)).toList();

        if (mounted) {
          setState(() {
            final existingIds = _reviews.map((r) => r.reviewId).toSet();
            for (var r in newReviews) {
              if (r.reviewId.isEmpty || !existingIds.contains(r.reviewId)) {
                _reviews.add(r);
                if (r.reviewId.isNotEmpty) existingIds.add(r.reviewId);
              }
            }
            _total = data['total'] ?? _reviews.length;
            _currentPage = data['page'] ?? nextPage;
            _totalPages = data['total_pages'] ?? _totalPages;
            _hasNext = data['has_next'] ?? (_reviews.length < _total);
          });
        }
      }
    } catch (e) {
      debugPrint("Error loading more reviews: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.providerId.isEmpty) {
      return const SizedBox.shrink();
    }

    final bool isBn = Get.locale?.languageCode == 'bn';

    return Container(
      width: double.infinity,
      margin: widget.margin ?? const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header
          if (widget.showHeader) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 22,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Ratings & Reviews'.tr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                if (!_isLoading && _reviews.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Text(
                      '${isBn ? _toBnDigits(_total) : _total} ${isBn ? 'টি রিভিউ' : 'Reviews'}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(height: 20),
          ],

          // Content States
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            )
          else if (_reviews.isEmpty)
            _buildEmptyState()
          else ...[
            // Review List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _reviews.length,
              separatorBuilder: (context, index) => const Divider(
                height: 20,
                thickness: 0.6,
                color: Color(0xFFF1F5F9),
              ),
              itemBuilder: (context, index) {
                return _buildReviewItem(_reviews[index]);
              },
            ),

            // Load More Button
            if (_hasNext || _isLoadingMore) ...[
              const SizedBox(height: 14),
              Center(
                child: _isLoadingMore
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                            strokeWidth: 2.2,
                          ),
                        ),
                      )
                    : InkWell(
                        onTap: loadMoreReviews,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.25),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isBn ? 'আরও রিভিউ দেখুন' : 'Load More Reviews',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.keyboard_arrow_down_rounded,
                                size: 18,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildReviewItem(ReviewItemModel review) {
    final bool isBn = Get.locale?.languageCode == 'bn';
    final String displayName = review.getReviewerDisplayName(isBn);

    final String initial = (!review.isAnonymous && displayName.isNotEmpty)
        ? displayName[0].toUpperCase()
        : 'A';

    final bool hasComment = (review.comment ?? '').trim().isNotEmpty;
    final String reviewKey = review.reviewId.isNotEmpty
        ? review.reviewId
        : '${review.reviewerName}_${review.createdAt.millisecondsSinceEpoch}';
    final bool isExpanded = _expandedReviewIds.contains(reviewKey);

    return InkWell(
      onTap: hasComment
          ? () {
              setState(() {
                if (isExpanded) {
                  _expandedReviewIds.remove(reviewKey);
                } else {
                  _expandedReviewIds.add(reviewKey);
                }
              });
            }
          : null,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Reviewer Info + Rating
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar: Privacy icon if anonymous, else 1st letter of reviewer's name
                CircleAvatar(
                  radius: 18,
                  backgroundColor: review.isAnonymous
                      ? Colors.grey.shade200
                      : AppColors.primary.withValues(alpha: 0.12),
                  child: review.isAnonymous
                      ? Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                          color: Colors.grey.shade600,
                        )
                      : Text(
                          initial,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                ),
                const SizedBox(width: 10),

                // Name + Time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: review.isAnonymous
                                    ? Colors.grey.shade700
                                    : Colors.black87,
                                fontStyle: review.isAnonymous
                                    ? FontStyle.italic
                                    : FontStyle.normal,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (review.isAnonymous) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.visibility_off_outlined,
                                    size: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    isBn ? 'গোপন' : 'Hidden',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      RichText(
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: review.formattedDateTime,
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            TextSpan(
                              text: ' • ${review.localizedTimeAgo(isBn)}',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Star Rating & Expand indicator if comment exists
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildStarRow(review.rating, iconSize: 14),
                    if (hasComment) ...[
                      const SizedBox(height: 3),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isExpanded
                                ? (isBn ? 'মন্তব্য লুকান' : 'Hide comment')
                                : (isBn ? 'মন্তব্য দেখুন' : 'View comment'),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: isExpanded
                                  ? AppColors.primary
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 2),
                          Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            size: 15,
                            color: isExpanded
                                ? AppColors.primary
                                : Colors.grey.shade600,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),

            // Collapsible Review Comment
            if (hasComment && isExpanded) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Text(
                  review.comment!.trim(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF334155),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStarRow(int rating, {double iconSize = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star_rounded : Icons.star_outline_rounded,
          color: Colors.amber,
          size: iconSize,
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 38,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 8),
          Text(
            'No reviews yet'.tr,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Customer reviews for this provider will appear here.'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

