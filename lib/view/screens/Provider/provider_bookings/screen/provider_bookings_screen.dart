import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../utils/app_colors/app_colors.dart';
import '../../../../components/custom_nav_bar/provider_nav_bar.dart';
import '../../../Seeker/seeker_bookings/model/seeker_booking_model.dart';
import '../controller/provider_bookings_controller.dart';

class ProviderBookingsScreen extends StatefulWidget {
  const ProviderBookingsScreen({super.key});

  @override
  State<ProviderBookingsScreen> createState() => _ProviderBookingsScreenState();
}

class _ProviderBookingsScreenState extends State<ProviderBookingsScreen> {
  late final ProviderBookingsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<ProviderBookingsController>()
        ? Get.find<ProviderBookingsController>()
        : Get.put(ProviderBookingsController());
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Bookings'.tr,
          style: const TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Obx(() {
              final activeCount = controller.activeBookings.length;
              final completedCount = controller.completedBookings.length;

              return TabBar(
                controller: controller.tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey.shade600,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Text(
                            'Upcoming Booking'.tr,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (activeCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$activeCount',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Completed'.tr),
                        if (completedCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$completedCount',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.green.shade800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
      bottomNavigationBar: const ProviderNavBar(currentIndex: 1),
      body: TabBarView(
        controller: controller.tabController,
        children: [
          // 1. Active Bookings Tab
          _buildActiveTab(),

          // 2. Completed Bookings Tab
          _buildCompletedTab(),
        ],
      ),
    );
  }

  Widget _buildActiveTab() {
    return Obx(() {
      if (controller.isLoadingActive.value &&
          controller.activeBookings.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      final list = controller.activeBookings;
      if (list.isEmpty) {
        return _buildEmptyState(
          title: 'No upcoming bookings'.tr,
          subtitle: 'You do not have any upcoming bookings right now.'.tr,
          onRefresh: () => controller.fetchActiveBookings(refresh: true),
        );
      }

      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => controller.fetchActiveBookings(refresh: true),
        child: ListView.builder(
          controller: controller.activeScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          itemCount: list.length + (controller.activeHasNext.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == list.length) {
              return controller.isLoadingMoreActive.value
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

            final booking = list[index];
            return _buildBookingCard(booking, isActiveTab: true);
          },
        ),
      );
    });
  }

  Widget _buildCompletedTab() {
    return Obx(() {
      if (controller.isLoadingCompleted.value &&
          controller.completedBookings.isEmpty) {
        return const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        );
      }

      final list = controller.completedBookings;
      if (list.isEmpty) {
        return _buildEmptyState(
          title: 'No completed bookings'.tr,
          subtitle: 'Completed service history will appear here.'.tr,
          onRefresh: () => controller.fetchCompletedBookings(refresh: true),
        );
      }

      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => controller.fetchCompletedBookings(refresh: true),
        child: ListView.builder(
          controller: controller.completedScrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final booking = list[index];
            return _buildBookingCard(booking, isActiveTab: false);
          },
        ),
      );
    });
  }

  Widget _buildBookingCard(
    BookingItemModel booking, {
    required bool isActiveTab,
  }) {
    final status = booking.status;
    final statusColor = _getStatusColor(status);
    final statusBg = _getStatusBgColor(status);
    final customerName = booking.otherPartyName.isNotEmpty
        ? booking.otherPartyName
        : 'Customer'.tr;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isActiveTab
              ? AppColors.primary.withValues(alpha: 0.4)
              : Colors.grey.shade200,
          width: isActiveTab ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isActiveTab
                ? AppColors.primary.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.openBookingDetails(
            booking.bookingId,
            skillName: booking.skillName,
            seekerName: customerName,
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
                    // Skill Name Pill (Flexible to prevent overflow)
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.handyman_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                booking.skillName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Status Badge (hidden for completed bookings to prevent overflow)
                    if (status != 'completed') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
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
                  ],
                ),

                const SizedBox(height: 12),

                // Middle Row: Customer Info
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.primary.withValues(
                        alpha: 0.12,
                      ),
                      child: Text(
                        customerName.isNotEmpty
                            ? customerName[0].toUpperCase()
                            : 'C',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(
                                Icons.person_pin_rounded,
                                size: 13,
                                color: Colors.grey.shade500,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Customer'.tr,
                                style: TextStyle(
                                  fontSize: 11.5,
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

                const Divider(height: 20),

                // Schedule / Date Row & View Details
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 13,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _formatDateTime(
                            booking.workSchedule ?? booking.createdAt,
                          ),
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'View Details →'.tr,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required String subtitle,
    required VoidCallback onRefresh,
  }) {
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
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.refresh, size: 16, color: Colors.white),
                label: Text(
                  'Refresh'.tr,
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
