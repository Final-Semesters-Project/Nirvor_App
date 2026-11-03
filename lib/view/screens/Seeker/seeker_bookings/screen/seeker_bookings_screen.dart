import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../utils/app_colors/app_colors.dart';
import '../../../../components/custom_nav_bar/navbar.dart';
import '../../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../controller/seeker_bookings_controller.dart';
import '../model/seeker_booking_model.dart';
import 'booking_details_screen.dart';

class SeekerBookingsScreen extends StatefulWidget {
  const SeekerBookingsScreen({super.key});

  @override
  State<SeekerBookingsScreen> createState() => _SeekerBookingsScreenState();
}

class _SeekerBookingsScreenState extends State<SeekerBookingsScreen> {
  late final SeekerBookingsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<SeekerBookingsController>()
        ? Get.find<SeekerBookingsController>()
        : Get.put(SeekerBookingsController());
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

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'IN PROGRESS / চলমান'.tr;
      case 'initiated':
        return 'INITIATED / শুরু হয়েছে'.tr;
      case 'completed':
        return 'COMPLETED / সম্পন্ন'.tr;
      case 'cancelled':
        return 'CANCELLED / বাতিল'.tr;
      case 'auto_expired':
        return 'EXPIRED / মেয়াদোত্তীর্ণ'.tr;
      default:
        return status.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomRoyelAppbar(
        titleName: 'My Bookings'.tr,
        leftIcon: false,
        centerTitleEnable: false,
        showLanguageSwitcher: false,
        titleSpacing: 20,
      ),
      bottomNavigationBar: const SeekerNavbar(currentIndex: 1),
      body: Obx(() {
        if (controller.isLoading.value && controller.bookings.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final displayList = controller.bookings;

        if (displayList.isEmpty) {
          return _buildEmptyState();
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.fetchBookings(refresh: true),
          child: ListView.builder(
            controller: controller.scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount:
                displayList.length + (controller.hasNext.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == displayList.length) {
                return controller.isLoadingMore.value
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.primary,
                          ),
                        ),
                      )
                    : const SizedBox.shrink();
              }

              final booking = displayList[index];
              return _buildBookingCard(booking);
            },
          ),
        );
      }),
    );
  }

  /// Booking Card styled like SearchResultsScreen
  Widget _buildBookingCard(BookingItemModel booking) {
    final status = booking.status;
    final statusColor = _getStatusColor(status);
    final statusBg = _getStatusBgColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: booking.isActive
              ? AppColors.primary.withValues(alpha: 0.5)
              : Colors.grey.shade200,
          width: booking.isActive ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: booking.isActive
                ? AppColors.primary.withValues(alpha: 0.06)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Get.to(
            () => BookingDetailsScreen(
              bookingId: booking.bookingId,
              skillName: booking.skillName,
              providerName: booking.otherPartyName,
              providerId: booking.providerId,
            ),
          ),
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Skill Badge + Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Skill Name Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.handyman_rounded,
                          size: 14, color: AppColors.primary),
                      const SizedBox(width: 5),
                      Text(
                        booking.skillName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    _getStatusLabel(status),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Middle Row: Provider Avatar & Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                  child: const Icon(
                    Icons.person,
                    size: 28,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.otherPartyName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      if (booking.isCancelled)
                        Text(
                          'Phone hidden (Cancelled)'.tr,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      else if (booking.otherPartyPhone != null &&
                          booking.otherPartyPhone!.isNotEmpty)
                        InkWell(
                          onTap: () =>
                              controller.callProvider(booking.otherPartyPhone),
                          child: Row(
                            children: [
                              Icon(
                                Icons.phone_rounded,
                                size: 13,
                                color: Colors.teal.shade700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                booking.otherPartyPhone!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.teal.shade700,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Text(
                          'Phone revealed on initiation'.tr,
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

            const SizedBox(height: 10),

            // Schedule & Time Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  if (booking.workSchedule != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.schedule_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${'Schedule'.tr}: ',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _formatDateTime(booking.workSchedule),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  if (booking.workSchedule != null) const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 13,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${'Booked On'.tr}: ',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          _formatDateTime(booking.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade800,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Bottom Action Buttons
            _buildActionButtons(booking),
          ],
        ),
      ),
    ),
  ),
);
  }

  /// Action Buttons depending on Booking Status
  Widget _buildActionButtons(BookingItemModel booking) {
    if (booking.isInProgress) {
      // In Progress -> 2 Buttons: (1) View Details, (2) Mark as Completed
      return Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: () => Get.to(
                () => BookingDetailsScreen(
                  bookingId: booking.bookingId,
                  skillName: booking.skillName,
                  providerName: booking.otherPartyName,
                  providerId: booking.providerId,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'View Details'.tr,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: () => controller.markAsCompleted(
                booking.bookingId,
                providerName: booking.otherPartyName,
              ),
              icon: const Icon(Icons.check_circle_rounded,
                  size: 16, color: Colors.white),
              label: Text(
                'Mark as Completed'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      );
    } else if (booking.isInitiated) {
      // Initiated -> 2 Buttons: (1) View Details, (2) Confirm Hire
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.to(
                () => BookingDetailsScreen(
                  bookingId: booking.bookingId,
                  skillName: booking.skillName,
                  providerName: booking.otherPartyName,
                  providerId: booking.providerId,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade400),
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'View Details'.tr,
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () => controller.showWorkSchedulePicker(
                booking.bookingId,
                providerName: booking.otherPartyName,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                'Confirm Hire'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      // Completed, Cancelled, Expired -> 1 full width button: View Details
      final isCancelled = booking.isCancelled;
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => Get.to(
            () => BookingDetailsScreen(
              bookingId: booking.bookingId,
              skillName: booking.skillName,
              providerName: booking.otherPartyName,
              providerId: booking.providerId,
            ),
          ),
          icon: Icon(
            Icons.info_outline_rounded,
            size: 16,
            color: isCancelled ? Colors.red.shade700 : AppColors.primary,
          ),
          label: Text(
            'View Details'.tr,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: isCancelled ? Colors.red.shade700 : AppColors.primary,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(
              color: isCancelled
                  ? Colors.red.shade300
                  : AppColors.primary,
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      );
    }
  }

  /// Empty state
  Widget _buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No bookings found'.tr,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'You do not have any bookings in this section.'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: () => controller.fetchBookings(refresh: true),
                icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                label: Text('Refresh'.tr,
                    style: const TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

