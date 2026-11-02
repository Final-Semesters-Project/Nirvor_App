import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../utils/app_colors/app_colors.dart';
import '../../../../components/custom_netwrok_image/custom_network_image.dart';
import '../../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../controller/seeker_bookings_controller.dart';
import '../model/seeker_booking_model.dart';

class BookingDetailsScreen extends StatefulWidget {
  final String bookingId;
  final String? skillName;
  final String? providerName;
  final String? providerId;

  const BookingDetailsScreen({
    super.key,
    required this.bookingId,
    this.skillName,
    this.providerName,
    this.providerId,
  });

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  late final SeekerBookingsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<SeekerBookingsController>()
        ? Get.find<SeekerBookingsController>()
        : Get.put(SeekerBookingsController());

    controller.fetchBookingDetail(widget.bookingId);
    if (widget.providerId != null && widget.providerId!.isNotEmpty) {
      controller.fetchProviderPublicProfile(widget.providerId!);
    }
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return '--';
    return DateFormat('dd MMM yyyy, hh:mm a').format(dt.toLocal());
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return Colors.blue.shade700;
      case 'initiated':
        return Colors.orange.shade800;
      case 'completed':
        return Colors.green.shade700;
      case 'cancelled':
      case 'auto_expired':
        return Colors.red.shade700;
      default:
        return AppColors.primary;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return Colors.blue.shade50;
      case 'initiated':
        return Colors.orange.shade50;
      case 'completed':
        return Colors.green.shade50;
      case 'cancelled':
      case 'auto_expired':
        return Colors.red.shade50;
      default:
        return AppColors.primary.withValues(alpha: 0.1);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return Icons.engineering_rounded;
      case 'initiated':
        return Icons.access_time_filled_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'cancelled':
      case 'auto_expired':
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String _getStatusTitle(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'In Progress / চলমান'.tr;
      case 'initiated':
        return 'Initiated / শুরু হয়েছে'.tr;
      case 'completed':
        return 'Completed / সম্পন্ন'.tr;
      case 'cancelled':
        return 'Cancelled / বাতিল'.tr;
      case 'auto_expired':
        return 'Expired / মেয়াদ উত্তীর্ণ'.tr;
      default:
        return status.toUpperCase();
    }
  }

  String _getStatusDesc(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'Provider hire is confirmed. Work is scheduled or currently under way.'.tr;
      case 'initiated':
        return 'Booking initiated. Please call provider and confirm schedule to finalize hire.'.tr;
      case 'completed':
        return 'This booking was marked as completed satisfactorily.'.tr;
      case 'cancelled':
        return 'This booking was cancelled.'.tr;
      case 'auto_expired':
        return 'This booking was automatically expired due to timeout.'.tr;
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomRoyelAppbar(
        titleName: 'Booking Details'.tr,
        leftIcon: true,
        centerTitleEnable: true,
      ),
      body: Obx(() {
        if (controller.isLoadingDetail.value &&
            controller.singleBookingDetail.value == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final detail = controller.singleBookingDetail.value;
        if (detail == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline_rounded,
                    size: 60, color: Colors.grey.shade400),
                const SizedBox(height: 12),
                Text(
                  'Booking details not found'.tr,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      controller.fetchBookingDetail(widget.bookingId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text('Retry'.tr,
                      style: const TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        final status = detail.status;
        final statusColor = _getStatusColor(status);
        final statusBg = _getStatusBgColor(status);
        final provider = controller.providerPublicProfile.value;
        final displayName = provider?.name.isNotEmpty == true
            ? provider!.name
            : (detail.otherPartyName.isNotEmpty
                ? detail.otherPartyName
                : (widget.providerName ?? 'Provider'));
        final displaySkill = widget.skillName ?? 'Skill Service';
        final photoUrl = provider?.photoUrl ?? '';

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await controller.fetchBookingDetail(widget.bookingId);
            if (detail.providerId != null) {
              await controller.fetchProviderPublicProfile(detail.providerId!);
            }
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Status Banner Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.35),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getStatusIcon(status),
                          color: statusColor,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusTitle(status),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getStatusDesc(status),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey.shade800,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Provider Public Profile Card (/api/v1/provider/{provider_id}/public)
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Provider Info'.tr,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              displaySkill,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),

                      // Provider Photo, Name, Rating & Verification
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Photo or Avatar
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: photoUrl.isNotEmpty
                                    ? CustomNetworkImage(
                                        imageUrl: photoUrl,
                                        height: 64,
                                        width: 64,
                                        borderRadius: BorderRadius.circular(12),
                                      )
                                    : Container(
                                        height: 64,
                                        width: 64,
                                        color: AppColors.primary
                                            .withValues(alpha: 0.12),
                                        child: Center(
                                          child: Text(
                                            displayName.isNotEmpty
                                                ? displayName[0].toUpperCase()
                                                : 'P',
                                            style: const TextStyle(
                                              fontSize: 26,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              if (provider?.isVerified == true)
                                Positioned(
                                  bottom: -2,
                                  right: -2,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.verified,
                                      color: AppColors.primary,
                                      size: 18,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        displayName,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (provider != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 7, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: provider.isVerified
                                              ? AppColors.primary
                                                  .withValues(alpha: 0.12)
                                              : Colors.grey.shade100,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          provider.verificationLevel
                                              .toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: provider.isVerified
                                                ? AppColors.primary
                                                : Colors.grey.shade700,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 4),

                                // Rating & Working Radius
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      provider != null &&
                                              provider.averageRating > 0
                                          ? provider.averageRating
                                              .toStringAsFixed(1)
                                          : 'New'.tr,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    if (provider != null &&
                                        provider.workingRadiusKm > 0) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '•',
                                        style: TextStyle(
                                            color: Colors.grey.shade400),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.radar_rounded,
                                        size: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 3),
                                      Text(
                                        '${provider.workingRadiusKm} km radius',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),

                                const SizedBox(height: 4),

                                // Phone number
                                if (detail.isCancelled)
                                  Text(
                                    'Phone hidden (Cancelled)'.tr,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  )
                                else if (detail.otherPartyPhone != null &&
                                    detail.otherPartyPhone!.isNotEmpty)
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.phone_rounded,
                                        size: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        detail.otherPartyPhone!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey.shade700,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  )
                                else
                                  Text(
                                    'Phone unlocked after booking'.tr,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // AI Review Summary (if available)
                      if (provider?.aiReviewSummary != null &&
                          provider!.aiReviewSummary!.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.purple.shade50,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Colors.purple.shade200,
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.auto_awesome,
                                size: 16,
                                color: Colors.purple.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  provider.aiReviewSummary!,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.purple.shade900,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Skills tags (if available)
                      if (provider != null && provider.skills.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: provider.skills.map((s) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(6),
                                border:
                                    Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                s.name,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],

                      // Call Provider button (hidden if cancelled)
                      if (!detail.isCancelled &&
                          detail.otherPartyPhone != null &&
                          detail.otherPartyPhone!.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () =>
                                controller.callProvider(detail.otherPartyPhone),
                            icon: const Icon(Icons.phone,
                                size: 16, color: Colors.white),
                            label: Text(
                              'Call Provider'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade700,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Work Schedule Card
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
                            Icons.schedule_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Work Schedule'.tr,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: detail.workSchedule != null
                            ? Row(
                                children: [
                                  const Icon(Icons.event_available_rounded,
                                      size: 20, color: AppColors.primary),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Scheduled Start Time'.tr,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          _formatDateTime(detail.workSchedule),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Icon(Icons.pending_actions_rounded,
                                      size: 20, color: Colors.orange.shade700),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'No work schedule specified yet'.tr,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade700,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Service Timeline
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
                            Icons.history_rounded,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Service Timeline'.tr,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildServiceTimeline(detail),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 5. Booking Reference ID
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.tag_rounded,
                          size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${'Booking ID'.tr}: ${detail.bookingId}',
                          style: TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            color: Colors.grey.shade700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16),
                        color: Colors.grey.shade600,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: detail.bookingId));
                          Get.snackbar(
                            'Copied'.tr,
                            'Booking ID copied to clipboard'.tr,
                            snackPosition: SnackPosition.BOTTOM,
                            duration: const Duration(seconds: 2),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 6. Action Buttons based on status
                if (detail.isInProgress) ...[
                  // Mark as Completed Button -> then Review Form shows!
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => controller.markAsCompleted(
                        detail.bookingId,
                        providerName: displayName,
                        photoUrl: photoUrl,
                      ),
                      icon: const Icon(Icons.check_circle_outline_rounded,
                          size: 18, color: Colors.white),
                      label: Text(
                        'Mark as Completed'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                      ),
                    ),
                  ),
                ] else if (detail.isInitiated) ...[
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () =>
                              controller.cancelBooking(detail.bookingId),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.red.shade400),
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Cancel Booking'.tr,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => controller.showWorkSchedulePicker(
                            detail.bookingId,
                            providerName: displayName,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Confirm & Hire'.tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else if (detail.isCompleted) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified,
                            color: Colors.green, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          'Job Completed Successfully'.tr,
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Button to Leave Review (shown only if not already reviewed)
                  Obx(() {
                    final hasReviewed = controller.isBookingReviewed(
                      detail.bookingId,
                      backendHasReviewed: detail.hasReviewed,
                    );

                    if (hasReviewed) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star_rounded,
                                color: Colors.amber.shade700, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'You have reviewed this provider'.tr,
                              style: TextStyle(
                                color: Colors.amber.shade900,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => controller.showReviewBottomSheet(
                          detail.bookingId,
                          providerName: displayName,
                          photoUrl: photoUrl,
                        ),
                        icon: const Icon(Icons.star_rounded,
                            size: 18, color: Colors.white),
                        label: Text(
                          'Rate & Review Provider'.tr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber.shade800,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 0,
                        ),
                      ),
                    );
                  }),
                ] else if (detail.isCancelled) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cancel_rounded,
                            color: Colors.red.shade700, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          detail.status.toLowerCase() == 'auto_expired'
                              ? 'Booking Expired'.tr
                              : 'Booking Cancelled'.tr,
                          style: TextStyle(
                            color: Colors.red.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 30),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildServiceTimeline(BookingDetailModel detail) {
    final bool isCancelled = detail.isCancelled;
    final bool isCallUnlockedDone = detail.callUnlockedAt != null ||
        detail.confirmedAt != null ||
        detail.isInProgress ||
        detail.isCompleted;
    final bool isConfirmedDone = detail.confirmedAt != null ||
        detail.isInProgress ||
        detail.isCompleted;
    final bool isCompletedDone =
        detail.isCompleted || detail.completedAt != null;

    if (isCancelled) {
      final bool hadCall = detail.callUnlockedAt != null;
      final bool hadConfirm = detail.confirmedAt != null;

      return Column(
        children: [
          _buildTimelineItem(
            icon: Icons.add_circle_outline_rounded,
            title: 'Initiated On'.tr,
            time: _formatDateTime(detail.createdAt),
            isDone: true,
            isLineDone: hadCall,
            isLast: false,
          ),
          if (hadCall)
            _buildTimelineItem(
              icon: Icons.phone_callback_rounded,
              title: 'Call Unlocked'.tr,
              time: _formatDateTime(detail.callUnlockedAt),
              isDone: true,
              isLineDone: hadConfirm,
              isLast: false,
            ),
          if (hadConfirm)
            _buildTimelineItem(
              icon: Icons.thumb_up_alt_rounded,
              title: 'Confirmed & Scheduled'.tr,
              time: _formatDateTime(detail.confirmedAt),
              isDone: true,
              isLineDone: false,
              isLast: false,
            ),
          _buildTimelineItem(
            icon: Icons.cancel_rounded,
            title: 'Cancelled'.tr,
            time: 'Booking was cancelled'.tr,
            isDone: true,
            isLineDone: false,
            isLast: true,
            isCancelled: true,
          ),
        ],
      );
    }

    // Normal track: Initiated -> Call Unlocked -> Confirmed & Scheduled -> Completed On
    return Column(
      children: [
        // 1. Initiated
        _buildTimelineItem(
          icon: Icons.add_circle_outline_rounded,
          title: 'Initiated On'.tr,
          time: _formatDateTime(detail.createdAt),
          isDone: true,
          isLineDone: isCallUnlockedDone,
          isLast: false,
        ),
        // 2. Call Unlocked (Number পাওয়া)
        _buildTimelineItem(
          icon: Icons.phone_callback_rounded,
          title: 'Call Unlocked'.tr,
          time: detail.callUnlockedAt != null
              ? _formatDateTime(detail.callUnlockedAt)
              : (isCallUnlockedDone
                  ? _formatDateTime(detail.createdAt)
                  : 'Pending'.tr),
          isDone: isCallUnlockedDone,
          isLineDone: isConfirmedDone,
          isLast: false,
        ),
        // 3. Confirmed & Scheduled
        _buildTimelineItem(
          icon: Icons.thumb_up_alt_rounded,
          title: 'Confirmed & Scheduled'.tr,
          time: detail.confirmedAt != null
              ? _formatDateTime(detail.confirmedAt)
              : (isConfirmedDone
                  ? _formatDateTime(detail.createdAt)
                  : 'Pending'.tr),
          isDone: isConfirmedDone,
          isLineDone: isCompletedDone,
          isLast: false,
        ),
        // 4. Completed On
        _buildTimelineItem(
          icon: Icons.verified_rounded,
          title: 'Completed On'.tr,
          time: detail.completedAt != null
              ? _formatDateTime(detail.completedAt)
              : (detail.isInProgress ? 'In Progress...'.tr : 'Pending'.tr),
          isDone: isCompletedDone,
          isLineDone: false,
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required String title,
    required String time,
    required bool isDone,
    required bool isLineDone,
    required bool isLast,
    bool isCancelled = false,
  }) {
    Color circleColor;
    Color iconColor;
    if (isCancelled) {
      circleColor = Colors.red.shade600;
      iconColor = Colors.white;
    } else if (isDone) {
      circleColor = AppColors.primary;
      iconColor = Colors.white;
    } else {
      circleColor = Colors.grey.shade100;
      iconColor = Colors.grey.shade400;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
                border: !isDone && !isCancelled
                    ? Border.all(color: Colors.grey.shade300, width: 1.5)
                    : null,
              ),
              child: Icon(icon, size: 14, color: iconColor),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isLineDone
                    ? AppColors.primary
                    : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isCancelled
                      ? Colors.red.shade700
                      : (isDone ? Colors.black87 : Colors.grey.shade600),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: isCancelled
                      ? Colors.red.shade400
                      : (isDone ? Colors.grey.shade600 : Colors.grey.shade400),
                ),
              ),
              if (!isLast) const SizedBox(height: 18),
            ],
          ),
        ),
      ],
    );
  }
}
