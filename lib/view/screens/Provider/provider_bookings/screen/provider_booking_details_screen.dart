import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../utils/app_colors/app_colors.dart';
import '../../../../components/custom_royel_appbar/custom_royel_appbar.dart';
import '../../../Seeker/seeker_bookings/model/seeker_booking_model.dart';
import '../controller/provider_bookings_controller.dart';

class ProviderBookingDetailsScreen extends StatefulWidget {
  final String bookingId;
  final String? skillName;
  final String? seekerName;

  const ProviderBookingDetailsScreen({
    super.key,
    required this.bookingId,
    this.skillName,
    this.seekerName,
  });

  @override
  State<ProviderBookingDetailsScreen> createState() =>
      _ProviderBookingDetailsScreenState();
}

class _ProviderBookingDetailsScreenState
    extends State<ProviderBookingDetailsScreen> {
  late final ProviderBookingsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ProviderBookingsController>()
        ? Get.find<ProviderBookingsController>()
        : Get.put(ProviderBookingsController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchBookingDetail(widget.bookingId);
    });
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
        return Icons.access_time_rounded;
      case 'completed':
        return Icons.check_circle_rounded;
      case 'cancelled':
      case 'auto_expired':
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }

  String _getStatusTitle(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'Job In Progress'.tr;
      case 'initiated':
        return 'Booking Initiated'.tr;
      case 'completed':
        return 'Job Completed'.tr;
      case 'cancelled':
        return 'Booking Cancelled'.tr;
      case 'auto_expired':
        return 'Booking Expired'.tr;
      default:
        return status.toUpperCase();
    }
  }

  String _getStatusDesc(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return 'You are currently working on this service request.'.tr;
      case 'initiated':
        return 'This booking has been initiated and schedule is confirmed.'.tr;
      case 'completed':
        return 'This job has been marked as completed successfully.'.tr;
      case 'cancelled':
        return 'This booking was cancelled by user or provider.'.tr;
      case 'auto_expired':
        return 'This booking was auto expired due to inactivity.'.tr;
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
        centerTitleEnable: false,
        showLanguageSwitcher: false,
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
                    color: Colors.grey.shade600,
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
        final customerName = detail.otherPartyName.isNotEmpty
            ? detail.otherPartyName
            : (widget.seekerName ?? 'Customer');
        final displaySkill = widget.skillName ?? 'Skill Service';

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () => controller.fetchBookingDetail(widget.bookingId),
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

                // 2. Customer Information Card
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
                            'Customer Information'.tr,
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

                      // Customer Avatar & Details
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 28,
                            backgroundColor:
                                AppColors.primary.withValues(alpha: 0.12),
                            child: Text(
                              customerName.isNotEmpty
                                  ? customerName[0].toUpperCase()
                                  : 'C',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
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
                                  customerName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.person_pin_rounded,
                                        size: 14, color: Colors.grey.shade500),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Customer'.tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),


                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Job Location Card (Coordinates + Google Maps Button)
                if (detail.jobLatitude != null &&
                    detail.jobLongitude != null) ...[
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
                            const Icon(Icons.location_on_rounded,
                                color: AppColors.primary, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Job Location'.tr,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${'Coordinates'.tr}: ${detail.jobLatitude!.toStringAsFixed(5)}, ${detail.jobLongitude!.toStringAsFixed(5)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () => controller.openMapLocation(
                              detail.jobLatitude,
                              detail.jobLongitude,
                            ),
                            icon: const Icon(Icons.directions_rounded,
                                size: 18, color: AppColors.primary),
                            label: Text(
                              'Open in Google Maps'.tr,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 4. Service Timeline Card
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
                          const Icon(Icons.timeline_rounded,
                              color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Service Progress'.tr,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
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

                // 5. Booking Metadata Summary
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
                      Text(
                        'Booking Summary'.tr,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Divider(height: 18),
                      _buildMetaRow(
                        'Booking ID'.tr,
                        detail.bookingId,
                        showCopy: true,
                        onCopy: () => controller.copyToClipboard(
                          detail.bookingId,
                          'Booking ID'.tr,
                        ),
                      ),
                      _buildMetaRow(
                        'Service'.tr,
                        displaySkill,
                      ),
                      _buildMetaRow(
                        'Created At'.tr,
                        _formatDateTime(detail.createdAt),
                      ),
                      if (detail.workSchedule != null)
                        _buildMetaRow(
                          'Work Schedule'.tr,
                          _formatDateTime(detail.workSchedule),
                          highlight: true,
                        ),
                      if (detail.completedAt != null)
                        _buildMetaRow(
                          'Completed At'.tr,
                          _formatDateTime(detail.completedAt),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // 6. Completion Banner (Note: Provider cannot complete or review himself)
                if (detail.isCompleted) ...[
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
      return Column(
        children: [
          _buildTimelineItem(
            icon: Icons.add_circle_outline_rounded,
            title: 'Initiated On'.tr,
            time: _formatDateTime(detail.createdAt),
            isDone: true,
            isLineDone: false,
            isLast: false,
          ),
          _buildTimelineItem(
            icon: Icons.cancel_outlined,
            title: 'Booking Terminated'.tr,
            time: _getStatusTitle(detail.status),
            isDone: true,
            isLineDone: false,
            isLast: true,
            isError: true,
          ),
        ],
      );
    }

    return Column(
      children: [
        _buildTimelineItem(
          icon: Icons.add_circle_outline_rounded,
          title: 'Initiated On'.tr,
          time: _formatDateTime(detail.createdAt),
          isDone: true,
          isLineDone: isCallUnlockedDone,
          isLast: false,
        ),
        _buildTimelineItem(
          icon: Icons.phone_callback_rounded,
          title: 'Call Unlocked'.tr,
          time: _formatDateTime(detail.callUnlockedAt),
          isDone: isCallUnlockedDone,
          isLineDone: isConfirmedDone,
          isLast: false,
        ),
        _buildTimelineItem(
          icon: Icons.thumb_up_alt_rounded,
          title: 'Confirmed & Scheduled'.tr,
          time: detail.workSchedule != null
              ? '${'Schedule'.tr}: ${_formatDateTime(detail.workSchedule)}'
              : _formatDateTime(detail.confirmedAt),
          isDone: isConfirmedDone,
          isLineDone: isCompletedDone,
          isLast: false,
        ),
        _buildTimelineItem(
          icon: Icons.verified_rounded,
          title: 'Completed'.tr,
          time: _formatDateTime(detail.completedAt),
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
    bool isError = false,
  }) {
    final Color itemColor = isError
        ? Colors.red.shade700
        : (isDone ? Colors.green.shade700 : Colors.grey.shade400);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: itemColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(color: itemColor, width: 1.5),
              ),
              child: Icon(icon, color: itemColor, size: 16),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 34,
                color: isLineDone ? Colors.green.shade700 : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isDone ? FontWeight.bold : FontWeight.w500,
                    color: isError
                        ? Colors.red.shade800
                        : (isDone ? Colors.black87 : Colors.grey.shade500),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetaRow(
    String label,
    String value, {
    bool highlight = false,
    bool showCopy = false,
    VoidCallback? onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12.5, color: Colors.grey.shade600),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight:
                          highlight ? FontWeight.bold : FontWeight.w600,
                      color: highlight ? AppColors.primary : Colors.black87,
                    ),
                    textAlign: TextAlign.end,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (showCopy && onCopy != null) ...[
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onCopy,
                    child: const Icon(Icons.copy_rounded,
                        size: 14, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

