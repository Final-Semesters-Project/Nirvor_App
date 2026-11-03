import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../../../model/review_model.dart';
import '../../../../../../utils/app_colors/app_colors.dart';
import '../../../../components/custom_text/custom_text.dart';
import '../controller/provider_home_controller.dart';

class ProviderAllReviewsScreen extends StatefulWidget {
  const ProviderAllReviewsScreen({super.key});

  @override
  State<ProviderAllReviewsScreen> createState() =>
      _ProviderAllReviewsScreenState();
}

class _ProviderAllReviewsScreenState extends State<ProviderAllReviewsScreen> {
  final ProviderHomeController controller =
      Get.find<ProviderHomeController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (controller.hasMoreReviews.value &&
          !controller.isLoadingMoreReviews.value) {
        controller.fetchProviderReviews(isRefresh: false);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isBn = Get.locale?.languageCode == 'bn';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A), size: 18),
          onPressed: () => Get.back(),
        ),
        title: CustomText(
          text: isBn ? 'সকল গ্রাহক রিভিউ' : 'All Customer Reviews',
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF0F172A),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final isLoading = controller.isLoadingReviews.value;
        final reviews = controller.reviewsList;
        final ratingVal = controller.dashboardData.value?.averageRating ?? 5.0;
        final ratingStr = ratingVal.toStringAsFixed(1);
        final totalCount = controller.totalReviewsCount.value > 0
            ? controller.totalReviewsCount.value
            : reviews.length;

        if (isLoading && reviews.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.fetchProviderReviews(isRefresh: true),
          child: ListView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            children: [
              // Rating Overview Card
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF0D9488)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F766E).withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              ratingStr,
                              style: TextStyle(
                                fontSize: 38.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '/ 5.0',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Icon(
                              i < ratingVal.floor()
                                  ? Icons.star_rounded
                                  : (i < ratingVal
                                      ? Icons.star_half_rounded
                                      : Icons.star_outline_rounded),
                              color: Colors.amber,
                              size: 18.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 14.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            totalCount.toString(),
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            isBn ? 'মোট রিভিউ' : 'Total Reviews',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 18.h),

              // Reviews Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBn ? 'গ্রাহকদের মন্তব্যসমূহ' : 'Customer Feedback',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    isBn ? '$totalCount টি রিভিউ' : '$totalCount Reviews',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Empty State
              if (reviews.isEmpty)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 48.h),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.rate_review_outlined,
                          size: 36.sp,
                          color: Colors.amber.shade700,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        isBn
                            ? 'এখনো কোনো রিভিউ পাওয়া যায়নি'
                            : 'No customer reviews yet',
                        style: TextStyle(
                          fontSize: 14.5.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        isBn
                            ? 'কাজ সম্পন্ন হলে ক্লায়েন্টরা এখানে রিভিউ দেবেন।'
                            : 'Client reviews will appear here once you complete bookings.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...reviews.map((review) => _buildReviewCard(review, isBn)),

              // Loading more indicator
              if (controller.isLoadingMoreReviews.value)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  child: const Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildReviewCard(ReviewItemModel review, bool isBn) {
    final String reviewerDisplayName = review.isAnonymous
        ? (isBn ? 'নাম প্রকাশে অনিচ্ছুক' : 'Anonymous Client')
        : (review.reviewerName.isNotEmpty
            ? review.reviewerName
            : (isBn ? 'গ্রাহক' : 'Client'));

    final String initial = reviewerDisplayName.isNotEmpty
        ? reviewerDisplayName[0].toUpperCase()
        : 'C';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 17.r,
                    backgroundColor: review.isAnonymous
                        ? Colors.grey.shade200
                        : AppColors.primary.withValues(alpha: 0.12),
                    child: review.isAnonymous
                        ? Icon(Icons.person_outline_rounded,
                            size: 18.sp, color: Colors.grey.shade600)
                        : Text(
                            initial,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reviewerDisplayName,
                        style: TextStyle(
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        review.localizedTimeAgo(isBn),
                        style: TextStyle(
                          fontSize: 10.5.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(
                  5,
                  (i) => Icon(
                    i < review.rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 16.sp,
                  ),
                ),
              ),
            ],
          ),
          if ((review.comment ?? '').trim().isNotEmpty) ...[
            SizedBox(height: 10.h),
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: 12.5.sp,
                color: const Color(0xFF334155),
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

