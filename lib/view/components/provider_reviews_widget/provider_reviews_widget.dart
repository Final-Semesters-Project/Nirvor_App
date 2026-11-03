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

  @override
  void initState() {
    super.initState();
    fetchReviews();
  }

  @override
  void didUpdateWidget(covariant ProviderReviewsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.providerId != widget.providerId && widget.providerId.isNotEmpty) {
      fetchReviews();
    }
  }

  Future<void> fetchReviews() async {
    if (widget.providerId.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    if (mounted) setState(() => _isLoading = true);

    try {
      final response = await ApiClient.getData(
        ApiUrl.providerReviews(widget.providerId),
      );

      if (response.statusCode == 200 && response.body != null) {
        final data = response.body;
        final List items = data['items'] ?? [];
        if (mounted) {
          setState(() {
            _reviews = items.map((e) => ReviewItemModel.fromJson(e)).toList();
            _total = data['total'] ?? _reviews.length;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _reviews = [];
            _total = 0;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching provider reviews: $e");
      if (mounted) {
        setState(() {
          _reviews = [];
          _total = 0;
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.providerId.isEmpty) {
      return const SizedBox.shrink();
    }

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
                      '$_total ${'Reviews'.tr}',
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

    return Column(
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
                  Row(
                    children: [
                      Text(
                        review.formattedDateTime,
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Text(
                        ' • ${review.localizedTimeAgo(isBn)}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Star Rating
            _buildStarRow(review.rating, iconSize: 14),
          ],
        ),

        // Review Comment
        if (review.comment != null && review.comment!.trim().isNotEmpty) ...[
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

