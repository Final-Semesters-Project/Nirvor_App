import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../service/api_client.dart';
import '../../../service/api_url.dart';
import '../../../utils/ToastMsg/toast_message.dart';
import '../../../utils/app_colors/app_colors.dart';
import '../../components/custom_netwrok_image/custom_network_image.dart';
import '../../components/custom_royel_appbar/custom_royel_appbar.dart';

class PostJobReviewScreen extends StatefulWidget {
  final String? bookingId;
  final String? providerName;
  final String? photoUrl;

  const PostJobReviewScreen({
    super.key,
    this.bookingId,
    this.providerName,
    this.photoUrl,
  });

  @override
  State<PostJobReviewScreen> createState() => _PostJobReviewScreenState();
}

class _PostJobReviewScreenState extends State<PostJobReviewScreen> {
  late final String bookingId;
  late final String providerName;
  late final String photoUrl;

  int selectedRating = 0;
  final TextEditingController commentController = TextEditingController();
  bool isAnonymous = true;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Support arguments passed via Get.arguments or widget parameters
    final args = Get.arguments is Map ? Get.arguments as Map : {};
    bookingId =
        widget.bookingId ?? args['booking_id']?.toString() ?? '';
    providerName = widget.providerName ??
        args['provider_name']?.toString() ??
        'Provider'.tr;
    photoUrl = widget.photoUrl ?? args['photo_url']?.toString() ?? '';
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  String _getRatingText(int rating) {
    switch (rating) {
      case 1:
        return 'rating_poor'.tr;
      case 2:
        return 'rating_fair'.tr;
      case 3:
        return 'rating_good'.tr;
      case 4:
        return 'rating_very_good'.tr;
      case 5:
        return 'rating_excellent'.tr;
      default:
        return 'tap_star_to_rate'.tr;
    }
  }

  Future<void> _submitReview() async {
    if (selectedRating == 0) {
      showCustomSnackBar('Please select a star rating first'.tr, isError: true);
      return;
    }

    if (bookingId.isEmpty) {
      showCustomSnackBar("Booking ID missing".tr, isError: true);
      return;
    }

    setState(() => isSubmitting = true);
    try {
      final body = {
        "booking_id": bookingId,
        "rating": selectedRating,
        if (commentController.text.trim().isNotEmpty)
          "comment": commentController.text.trim(),
        "is_anonymous": isAnonymous,
      };

      final response = await ApiClient.postData(ApiUrl.reviews, body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        showCustomSnackBar(
          "Thank you! Your review has been submitted.".tr,
          isError: false,
        );
        Get.back(result: true);
      } else {
        String msg = "Could not submit review".tr;
        if (response.body is Map && response.body['detail'] != null) {
          msg = response.body['detail'].toString();
        }
        showCustomSnackBar(msg, isError: true);
      }
    } catch (e) {
      debugPrint("Error submitting review: $e");
      showCustomSnackBar("Something went wrong".tr, isError: true);
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomRoyelAppbar(
        titleName: 'Post-Job Review'.tr,
        leftIcon: true,
        centerTitleEnable: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Provider Info Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: photoUrl.isNotEmpty
                        ? CustomNetworkImage(
                            imageUrl: photoUrl,
                            height: 60,
                            width: 60,
                            borderRadius: BorderRadius.circular(12),
                          )
                        : Container(
                            height: 60,
                            width: 60,
                            color: AppColors.primary.withValues(alpha: 0.12),
                            child: const Icon(
                              Icons.person,
                              size: 34,
                              color: AppColors.primary,
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          providerName,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'How was your overall experience?'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Rating Stars
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Text(
                    'Rate your service'.tr,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starNum = index + 1;
                      final isFilled = starNum <= selectedRating;
                      return IconButton(
                        iconSize: 42,
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        icon: Icon(
                          isFilled
                              ? Icons.star_rounded
                              : Icons.star_outline_rounded,
                          color: isFilled
                              ? Colors.amber.shade600
                              : Colors.grey.shade300,
                        ),
                        onPressed: () {
                          setState(() => selectedRating = starNum);
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getRatingText(selectedRating),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Comment Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Write a Review (Optional)'.tr,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText:
                          'Share details of your experience with this service...'.tr,
                      hintStyle: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                      fillColor: Colors.grey.shade50,
                      filled: true,
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Anonymous Switch
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: CheckboxListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                title: Text(
                  'Submit review anonymously'.tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                subtitle: Text(
                  'Your name will not appear on public reviews'.tr,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
                value: isAnonymous,
                activeColor: AppColors.primary,
                onChanged: (val) {
                  setState(() => isAnonymous = val ?? true);
                },
              ),
            ),

            const SizedBox(height: 28),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 1,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'Submit Review'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
