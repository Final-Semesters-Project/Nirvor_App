import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../core/app_routes/app_routes.dart';
import '../../../../../utils/ToastMsg/toast_message.dart';
import '../../home_provider/controller/provider_home_controller.dart';
import '../model/urgent_broadcast_model.dart';

class ProviderActiveUrgentJobScreen extends StatefulWidget {
  final ActiveUrgentJobModel job;

  const ProviderActiveUrgentJobScreen({
    super.key,
    required this.job,
  });

  @override
  State<ProviderActiveUrgentJobScreen> createState() =>
      _ProviderActiveUrgentJobScreenState();
}

class _ProviderActiveUrgentJobScreenState
    extends State<ProviderActiveUrgentJobScreen> {
  GoogleMapController? _mapController;

  Future<void> _makePhoneCall(String phone) async {
    if (phone.isEmpty) {
      showCustomSnackBar("গ্রাহকের ফোন নম্বর পাওয়া যায়নি / Phone number not found",
          isError: true);
      return;
    }
    final uri = Uri.parse("tel:$phone");
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      showCustomSnackBar("কল করা সম্ভব হয়নি: $e", isError: true);
    }
  }

  Future<void> _openGoogleMaps(double lat, double lng) async {
    if (lat == 0.0 && lng == 0.0) {
      showCustomSnackBar("গ্রাহকের লোকেশন পাওয়া যায়নি / Location not available",
          isError: true);
      return;
    }
    final uri = Uri.parse(
      "https://www.google.com/maps/dir/?api=1&destination=$lat,$lng",
    );
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        showCustomSnackBar("ম্যাপ খোলা সম্ভব হয়নি", isError: true);
      }
    } catch (e) {
      showCustomSnackBar("ম্যাপ খোলা সম্ভব হয়নি: $e", isError: true);
    }
  }

  void _showCompleteDialog() {
    final bool isBn = Get.locale?.languageCode == 'bn';
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green.shade600,
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                isBn ? 'কাজ সম্পন্ন হয়েছে?' : 'Job Completed?',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isBn
                    ? 'আপনি কি গ্রাহকের জরুরি সেবা সম্পন্ন করেছেন? নিশ্চিত করলে এটি সমাপ্ত হিসেবে চিহ্নিত হবে।'
                    : 'Have you completed the urgent service for the client? Confirming will complete this dispatch.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isBn ? 'না' : 'Cancel',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        // Clear active urgent job
                        await clearActiveUrgentJob();
                        if (Get.isRegistered<ProviderHomeController>()) {
                          Get.find<ProviderHomeController>()
                              .setActiveUrgentJob(null);
                        }
                        showCustomSnackBar(
                          isBn
                              ? 'কাজটি সফলভাবে সম্পন্ন হয়েছে! ধন্যবাদ।'
                              : 'Urgent job completed successfully! Thank you.',
                          isError: false,
                        );
                        Get.offAllNamed(AppRoutes.providerHomeScreen);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        isBn ? 'হ্যাঁ, সম্পন্ন' : 'Yes, Complete',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final job = widget.job;
    final bool isBn = Get.locale?.languageCode == 'bn';
    final hasValidCoords = job.seekerLatitude != 0.0 && job.seekerLongitude != 0.0;
    final seekerPos = LatLng(job.seekerLatitude, job.seekerLongitude);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F766E),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Return to home screen while keeping job active
            Get.offAllNamed(AppRoutes.providerHomeScreen);
          },
        ),
        title: Text(
          isBn ? 'চলমান জরুরি কাজ' : 'Active Urgent Job',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4ADE80),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isBn ? 'চলমান' : 'In Progress',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Service Type Card with Lightning Icon
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF991B1B), Color(0xFFDC2626)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.25),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.bolt_rounded,
                      color: Colors.amber,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isBn ? 'জরুরি সেবা অনুরোধ' : 'Urgent Service Request',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          job.skillName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (job.distanceKm > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isBn
                            ? '${job.distanceKm.toStringAsFixed(1)} কিমি দূরে'
                            : '${job.distanceKm.toStringAsFixed(1)} km',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 2. Seeker Contact Details Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Color(0xFF0F766E),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn ? 'গ্রাহকের নাম' : 'Client Name',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              job.seekerName.isNotEmpty
                                  ? job.seekerName
                                  : (isBn ? 'সেবাপ্রার্থী' : 'Client'),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: Colors.grey.shade100),
                  const SizedBox(height: 14),

                  // Phone row with direct Call Button
                  Row(
                    children: [
                      Icon(Icons.phone_outlined,
                          size: 20, color: Colors.grey.shade600),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          job.seekerPhone.isNotEmpty
                              ? job.seekerPhone
                              : (isBn ? 'ফোন নম্বর পাওয়া যায়নি' : 'No phone number'),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: job.seekerPhone.isNotEmpty
                                ? const Color(0xFF0F172A)
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Big Green Call Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: job.seekerPhone.isNotEmpty
                          ? () => _makePhoneCall(job.seekerPhone)
                          : null,
                      icon: const Icon(Icons.call, color: Colors.white, size: 20),
                      label: Text(
                        isBn ? 'গ্রাহককে সরাসরি কল করুন' : 'Call Client Now',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF16A34A),
                        disabledBackgroundColor: Colors.grey.shade300,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 3. Location & Directions Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0284C7).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFF0284C7),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isBn ? 'কাজের লোকেশন' : 'Service Location',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              hasValidCoords
                                  ? (isBn ? 'ম্যাপে চিহ্নিত অবস্থান' : 'Pinned Location')
                                  : (isBn ? 'লোকেশন উপলব্ধ নেই' : 'Location not available'),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Mini Google Map Preview if coordinates are available
                  if (hasValidCoords) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 160,
                        width: double.infinity,
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: seekerPos,
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId('seeker_location'),
                              position: seekerPos,
                              infoWindow: InfoWindow(
                                title: job.seekerName,
                                snippet: job.skillName,
                              ),
                            ),
                          },
                          zoomControlsEnabled: false,
                          myLocationButtonEnabled: false,
                          onMapCreated: (ctrl) => _mapController = ctrl,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Directions Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: hasValidCoords
                          ? () => _openGoogleMaps(
                                job.seekerLatitude,
                                job.seekerLongitude,
                              )
                          : null,
                      icon: const Icon(Icons.directions_rounded,
                          color: Color(0xFF0284C7), size: 22),
                      label: Text(
                        isBn
                            ? 'গুগল ম্যাপে দিকনির্দেশনা দেখুন'
                            : 'Get Directions on Google Maps',
                        style: const TextStyle(
                          color: Color(0xFF0284C7),
                          fontSize: 14.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF0284C7)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 4. Important Guidance Note
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 20, color: Colors.amber.shade800),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isBn
                          ? 'গ্রাহকের ঠিকানায় যাওয়ার আগে ফোন করে কাজের বিস্তারিত ও প্রয়োজনীয় সরঞ্জাম সম্পর্কে নিশ্চিত হন। কাজ শেষ হলে নিচের বাটনে ট্যাপ করে সম্পন্ন করুন।'
                          : 'Please call the client before dispatching to confirm service requirements. Once done, tap the Complete button below.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber.shade900,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 5. Complete Job Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _showCompleteDialog,
                icon: const Icon(Icons.check_circle_outline, color: Colors.white),
                label: Text(
                  isBn ? 'কাজ সম্পন্ন হয়েছে (Complete Job)' : 'Complete Job',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Back to Dashboard Button
            SizedBox(
              width: double.infinity,
              height: 44,
              child: TextButton(
                onPressed: () {
                  Get.offAllNamed(AppRoutes.providerHomeScreen);
                },
                child: Text(
                  isBn ? 'ড্যাশবোর্ডে ফিরে যান (Back to Dashboard)' : 'Back to Dashboard',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
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

