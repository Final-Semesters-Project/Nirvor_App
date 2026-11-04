import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../../model/provider_model.dart';
import '../../../../../../utils/ToastMsg/toast_message.dart';
import '../../../../../../utils/app_colors/app_colors.dart';
import '../../../../../components/custom_netwrok_image/custom_network_image.dart';
import '../../../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../../../../../components/provider_reviews_widget/provider_reviews_widget.dart';
import '../../../seeker_bookings/model/seeker_booking_model.dart';
import '../../controller/home_seeker_controller.dart';

class ProviderPublicDetailsScreen extends StatefulWidget {
  final String providerId;
  final String? providerName;
  final String? providerPhone;
  final String? photoUrl;
  final String? bookingId;
  final bool hasActiveBooking;
  final ProviderModel? providerModel;

  const ProviderPublicDetailsScreen({
    super.key,
    required this.providerId,
    this.providerName,
    this.providerPhone,
    this.photoUrl,
    this.bookingId,
    this.hasActiveBooking = false,
    this.providerModel,
  });

  @override
  State<ProviderPublicDetailsScreen> createState() =>
      _ProviderPublicDetailsScreenState();
}

class _ProviderPublicDetailsScreenState
    extends State<ProviderPublicDetailsScreen> {
  final HomeSeekerController controller =
      Get.isRegistered<HomeSeekerController>()
          ? Get.find<HomeSeekerController>()
          : Get.put(HomeSeekerController());

  @override
  void initState() {
    super.initState();
    if (widget.providerId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.fetchPublicProviderProfile(widget.providerId);
      });
    }
  }

  Future<void> _makePhoneCall(String phone) async {
    if (phone.isEmpty) {
      showCustomSnackBar("Number not available".tr, isError: true);
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      showCustomSnackBar('Could not launch phone app'.tr, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomRoyelAppbar(
        titleName: 'Provider Details'.tr,
        leftIcon: true,
        centerTitleEnable: true,
      ),
      bottomNavigationBar: _buildBottomActionBar(),
      body: Obx(() {
        final PublicProviderModel? publicProfile =
            controller.publicProviderProfile.value;
        final bool isLoading = controller.isLoadingPublicProfile.value;

        // Fallbacks from widget or providerModel
        final String displayName = publicProfile?.name.isNotEmpty == true
            ? publicProfile!.name
            : (widget.providerName ?? widget.providerModel?.name ?? 'Provider');

        final String displayPhoto = publicProfile?.photoUrl?.isNotEmpty == true
            ? publicProfile!.photoUrl!
            : (widget.photoUrl ?? widget.providerModel?.photoUrl ?? '');

        final String phone = widget.providerPhone ??
            widget.providerModel?.phoneEn ??
            '';

        final String verification = publicProfile?.verificationLevel ??
            widget.providerModel?.verificationLevel ??
            'basic';

        final bool isVerified =
            verification.toLowerCase() == 'verified' ||
            verification.toLowerCase() == 'trusted';

        final double rating = publicProfile?.averageRating ??
            widget.providerModel?.averageRating ??
            0.0;

        final int radiusKm = publicProfile?.workingRadiusKm ??
            widget.providerModel?.workingRadiusKm.toInt() ??
            0;

        final bool hasSmartphone = publicProfile?.hasSmartphone ??
            widget.providerModel?.hasSmartphone ??
            false;

        final bool isAvailable = publicProfile?.isAvailable ??
            widget.providerModel?.isAvailable ??
            true;

        final String? aiSummary = publicProfile?.aiReviewSummary;

        final List<String> skillList = publicProfile != null
            ? publicProfile.skills.map((s) => s.name).toList()
            : (widget.providerModel?.skillNames ?? []);

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            if (widget.providerId.isNotEmpty) {
              await controller.fetchPublicProviderProfile(widget.providerId);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isLoading && publicProfile == null)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(
                      color: AppColors.primary,
                      minHeight: 2,
                    ),
                  ),

                // Active Booking Notice Banner (if opened during active booking)
                if (widget.hasActiveBooking) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.bolt_rounded,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'active_booking_banner_hint'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blueGrey.shade900,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 1. Profile Header Card
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
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Avatar & Verified Badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                                width: 2.5,
                              ),
                            ),
                            child: ClipOval(
                              child: displayPhoto.isNotEmpty
                                  ? CustomNetworkImage(
                                      imageUrl: displayPhoto,
                                      height: 84,
                                      width: 84,
                                      borderRadius: BorderRadius.circular(42),
                                    )
                                  : CircleAvatar(
                                      radius: 42,
                                      backgroundColor: AppColors.primary
                                          .withValues(alpha: 0.12),
                                      child: Text(
                                        displayName.isNotEmpty
                                            ? displayName[0].toUpperCase()
                                            : 'P',
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          if (isVerified)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.verified,
                                  color: AppColors.primary,
                                  size: 22,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Name
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),

                      // Badges Row (Verification & Availability)
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isVerified
                                  ? AppColors.primary.withValues(alpha: 0.12)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              (verification.toLowerCase() == 'basic' ||
                                      verification.isEmpty)
                                  ? 'UNVERIFIED'.tr
                                  : verification.toUpperCase().tr,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isVerified
                                    ? AppColors.primary
                                    : Colors.grey.shade700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? Colors.green.shade50
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isAvailable
                                    ? Colors.green.shade300
                                    : Colors.grey.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isAvailable
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isAvailable
                                      ? 'Available'.tr
                                      : 'Unavailable'.tr,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: isAvailable
                                        ? Colors.green.shade800
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Rating & Working Radius Summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                size: 20,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                rating > 0
                                    ? '${rating.toStringAsFixed(1)} / 5.0'
                                    : 'New'.tr,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          if (radiusKm > 0) ...[
                            Container(
                              height: 14,
                              width: 1,
                              margin: const EdgeInsets.symmetric(horizontal: 14),
                              color: Colors.grey.shade300,
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.radar,
                                  size: 16,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '$radiusKm KM Radius',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),

                      // Phone Number section (if available)
                      if (phone.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal.shade50.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.teal.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.phone_rounded,
                                    size: 16,
                                    color: Colors.teal.shade800,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    phone,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade900,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _makePhoneCall(phone),
                                icon: const Icon(Icons.call,
                                    size: 14, color: Colors.white),
                                label: Text(
                                  'Call'.tr,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal.shade700,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Skills Offered Card
                Container(
                  width: double.infinity,
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
                      Row(
                        children: [
                          const Icon(
                            Icons.handyman_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Skills Offered'.tr,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (skillList.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: skillList.map((skillName) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                skillName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                            );
                          }).toList(),
                        )
                      else
                        Text(
                          'General Service'.tr,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),

                // 3. AI Review Summary Card (if available)
                if (aiSummary != null && aiSummary.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.purple.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 18,
                              color: Colors.purple.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'AI Review Summary'.tr,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          aiSummary,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.purple.shade900,
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // 4. Quick Info (Smartphone & Working Radius)
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
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
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: Colors.grey.shade700,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Quick Info'.tr,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoItem(
                              icon: Icons.radar,
                              label: 'Working Radius'.tr,
                              value: '$radiusKm KM',
                            ),
                          ),
                          Expanded(
                            child: _buildInfoItem(
                              icon: Icons.smartphone,
                              label: 'Smartphone'.tr,
                              value: hasSmartphone ? 'Yes'.tr : 'No'.tr,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 5. Customer Reviews Section (/api/v1/reviews/provider/{provider_id})
                ProviderReviewsWidget(
                  providerId: widget.providerId,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  /// Bottom Bar matching SearchResultsScreen screenshot:
  /// Two buttons: [ Cancel ] and [ Confirm Hire ]
  Widget? _buildBottomActionBar() {
    final effectiveBookingId = widget.bookingId ??
        controller.activeBookingData.value?['booking_id']?.toString();

    final effectiveProviderName = widget.providerName ??
        widget.providerModel?.name ??
        controller.activeBookingData.value?['provider_name'] ??
        'Provider';

    if (widget.hasActiveBooking &&
        effectiveBookingId != null &&
        effectiveBookingId.isNotEmpty) {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              // Cancel Button
              Expanded(
                child: Obx(
                  () => OutlinedButton(
                    onPressed: (controller.isCancellingBooking.value ||
                            controller.isConfirmingBooking.value)
                        ? null
                        : () => controller.cancelBooking(effectiveBookingId),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: controller.isCancellingBooking.value
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Text(
                            'Cancel'.tr,
                            style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Confirm Hire Button
              Expanded(
                child: Obx(
                  () => ElevatedButton(
                    onPressed: (controller.isCancellingBooking.value ||
                            controller.isConfirmingBooking.value)
                        ? null
                        : () => controller.showWorkSchedulePicker(
                              effectiveBookingId,
                              providerName: effectiveProviderName,
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: controller.isConfirmingBooking.value
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            'Confirm Hire'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (!widget.hasActiveBooking && widget.providerModel != null) {
      // Direct Search list view without active booking -> Request to Call
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Obx(
            () => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: controller.isInitiatingBooking.value
                    ? null
                    : () {
                        Get.back();
                        controller.initiateBooking(widget.providerModel!);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: controller.isInitiatingBooking.value
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        'request_to_call'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ),
        ),
      );
    }

    return null;
  }
}

