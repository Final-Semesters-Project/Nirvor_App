import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import '../../../../../helper/shared_prefe/shared_prefe.dart';
import '../../../../../model/category_model.dart';
import '../../../../../model/skill_model.dart';
import '../../../../../model/provider_model.dart';
import '../../../../../service/api_client.dart';
import '../../../../../service/api_url.dart';
import '../../../../../utils/ToastMsg/toast_message.dart';
import '../../../../../utils/app_colors/app_colors.dart';
import '../../seeker_profile/controller/seeker_profile_controller.dart';
import '../../seeker_bookings/model/seeker_booking_model.dart' show PublicProviderModel;

class HomeSeekerController extends GetxController {
  final CustomInfoWindowController customInfoWindowController =
      CustomInfoWindowController();
  var selectedCategoryIndex = (-1).obs;
  var currentCategoryId = 0.obs;

  var categories = <CategoryModel>[].obs;
  var skills = <SkillModel>[].obs;
  var providers = <ProviderModel>[].obs;

  // Pagination and parameters for Provider Search (/api/v1/search/providers)
  final ScrollController searchScrollController = ScrollController();
  var searchRadiusKm = 1.obs; // Search radius in km (initial: 1, max: 5, valid: 1-5 integer)
  var searchPageSize = 20.obs; // Page size (default: 20)
  var currentSearchPage = 1.obs;
  var totalSearchPages = 1.obs;
  var hasNextSearchPage = false.obs;
  var isLoadingMoreProviders = false.obs;

  var isLoadingCategories = false.obs;
  var isLoadingSkills = false.obs;
  var isLoadingProviders = false.obs;

  var markers = <Marker>{}.obs;
  var initialPosition = const LatLng(23.7947, 90.4010).obs;

  // Active initiated booking state
  var hasActiveBooking = false.obs;
  var activeBookingData = Rxn<Map<String, dynamic>>();
  var isCancellingBooking = false.obs;
  var isConfirmingBooking = false.obs;
  bool get isBookingActionLoading =>
      isCancellingBooking.value || isConfirmingBooking.value;
  var isInitiatingBooking = false.obs;

  // Provider public profile state
  var publicProviderProfile = Rxn<PublicProviderModel>();
  var isLoadingPublicProfile = false.obs;

  /// Fetch provider public profile: GET /api/v1/provider/{provider_id}/public
  Future<void> fetchPublicProviderProfile(String providerId) async {
    if (providerId.isEmpty) return;
    isLoadingPublicProfile.value = true;
    try {
      final response = await ApiClient.getData(
        ApiUrl.providerPublicProfile(providerId),
      );
      if (response.statusCode == 200 && response.body != null) {
        publicProviderProfile.value =
            PublicProviderModel.fromJson(response.body);
      }
    } catch (e) {
      debugPrint("Error fetching public provider profile: $e");
    } finally {
      isLoadingPublicProfile.value = false;
    }
  }

  // Last search query context for booking initiate
  var currentSkillId = 0.obs;
  var currentSkillName = ''.obs;
  double seekerLat = 0.0;
  double seekerLng = 0.0;

  // Location choice: 'current' (GPS) or 'home' (Saved home address)
  var selectedLocationMode = 'current'.obs;
  var selectedLocationAddress = ''.obs;
  var homeAddress = ''.obs;
  var homeLatitude = 0.0.obs;
  var homeLongitude = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    searchScrollController.addListener(_onSearchScroll);
    getCategories();
    checkActiveBooking();
    loadHomeLocationData();
  }

  void _onSearchScroll() {
    if (searchScrollController.hasClients) {
      if (searchScrollController.position.pixels >=
          searchScrollController.position.maxScrollExtent - 250) {
        if (hasNextSearchPage.value &&
            !isLoadingMoreProviders.value &&
            !isLoadingProviders.value) {
          loadMoreProviders();
        }
      }
    }
  }

  @override
  void onClose() {
    searchScrollController.dispose();
    super.onClose();
  }

  Future<void> loadHomeLocationData() async {
    try {
      String addr = await SharePrefsHelper.getString("seeker_home_address");
      String latStr = await SharePrefsHelper.getString("seeker_home_lat");
      String lngStr = await SharePrefsHelper.getString("seeker_home_lng");

      if (addr.isNotEmpty) {
        homeAddress.value = addr;
      }
      if (latStr.isNotEmpty) {
        homeLatitude.value = double.tryParse(latStr) ?? 0.0;
      }
      if (lngStr.isNotEmpty) {
        homeLongitude.value = double.tryParse(lngStr) ?? 0.0;
      }

      if (Get.isRegistered<SeekerProfileController>()) {
        final profileCtrl = Get.find<SeekerProfileController>();
        if (profileCtrl.user.value != null &&
            profileCtrl.user.value!.homeAddress.isNotEmpty) {
          if (homeAddress.value.isEmpty) {
            homeAddress.value = profileCtrl.user.value!.homeAddress;
          }
          if (homeLatitude.value == 0.0 &&
              profileCtrl.user.value!.homeLatitude != null) {
            homeLatitude.value = profileCtrl.user.value!.homeLatitude!;
          }
          if (homeLongitude.value == 0.0 &&
              profileCtrl.user.value!.homeLongitude != null) {
            homeLongitude.value = profileCtrl.user.value!.homeLongitude!;
          }
        }
      }
    } catch (e) {
      debugPrint("Error loading home location: $e");
    }
  }

  void selectCategory(int index) {
    if (categories.isEmpty || index < 0 || index >= categories.length) return;

    final bool isSameCategory = selectedCategoryIndex.value == index;
    selectedCategoryIndex.value = index;
    final categoryId = categories[index].id;

    // If the same category is clicked and skills for this category are already loaded,
    // open the bottom sheet immediately without waiting for API
    if (isSameCategory && skills.isNotEmpty && currentCategoryId.value == categoryId) {
      _showSkillsBottomSheet();
    } else {
      getSkills(categoryId);
    }
  }

  /// Check if the seeker currently has an active INITIATED booking
  Future<void> checkActiveBooking() async {
    try {
      final response = await ApiClient.getData(ApiUrl.activeBooking);
      if (response.statusCode == 200 && response.body != null) {
        bool hasActive = response.body['has_active_booking'] ?? false;
        hasActiveBooking.value = hasActive;
        if (hasActive && response.body['booking'] != null) {
          final bookingMap = Map<String, dynamic>.from(response.body['booking']);
          if (bookingMap['provider_id'] == null) {
            final pName = bookingMap['provider_name'];
            final match = providers.firstWhereOrNull((p) => p.name == pName);
            if (match != null) {
              bookingMap['provider_id'] = match.userId;
            }
          }
          activeBookingData.value = bookingMap;
        } else {
          activeBookingData.value = null;
        }
      } else {
        hasActiveBooking.value = false;
        activeBookingData.value = null;
      }
    } catch (e) {
      debugPrint("Error checking active booking: $e");
    }
  }

  Future<void> getCategories() async {
    isLoadingCategories.value = true;
    final response = await ApiClient.getData(ApiUrl.categoryList);
    isLoadingCategories.value = false;
    if (response.statusCode == 200) {
      List data = response.body;
      categories.value = data.map((e) => CategoryModel.fromJson(e)).toList();
    }
  }

  Future<void> getSkills(int categoryId) async {
    currentCategoryId.value = categoryId;
    isLoadingSkills.value = true;
    final response = await ApiClient.getData(
      ApiUrl.skillList(categoryId.toString()),
    );
    isLoadingSkills.value = false;
    if (response.statusCode == 200) {
      List data = response.body;
      skills.value = data.map((e) => SkillModel.fromJson(e)).toList();
      _showSkillsBottomSheet();
    }
  }

  void _showSkillsBottomSheet() {
    final bool isBn = Get.locale?.languageCode == 'bn';
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        child: SafeArea(
          bottom: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isBn ? "দক্ষতা নির্বাচন করুন" : "Select a Skill",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (skills.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Center(
                    child: Text(
                      isBn ? "কোনো দক্ষতা পাওয়া যায়নি" : "No skills available",
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  children: skills.map((skill) {
                    final bool isCurrentSkill = currentSkillId.value == skill.id;
                    return ActionChip(
                      backgroundColor: isCurrentSkill
                          ? AppColors.primary
                          : const Color(0xFFF1F5F9),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isCurrentSkill
                              ? AppColors.primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      avatar: isCurrentSkill
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                      label: Text(
                        skill.name,
                        style: TextStyle(
                          color: isCurrentSkill ? Colors.white : Colors.black87,
                          fontWeight: isCurrentSkill
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      onPressed: () {
                        Get.back();
                        currentSkillId.value = skill.id;
                        currentSkillName.value = skill.name;
                        showRadiusSelectionSheet(skill.id, skill.name);
                      },
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  String toBnDigits(int number) {
    if (Get.locale?.languageCode == 'bn') {
      const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
      return number.toString().split('').map((char) {
        int? idx = int.tryParse(char);
        return idx != null ? bnDigits[idx] : char;
      }).join();
    }
    return number.toString();
  }

  /// Show modal bottom sheet to select search radius (1 - 5 km)
  void showRadiusSelectionSheet(int skillId, String skillName) {
    final bool isBn = Get.locale?.languageCode == 'bn';
    // Initial value is 1, max is 5, integers 1-5 only (no fractions)
    final RxInt selectedKm = (searchRadiusKm.value >= 1 && searchRadiusKm.value <= 5
            ? searchRadiusKm.value
            : 1)
        .obs;

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: SafeArea(
          bottom: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.radar_rounded,
                            color: AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Select Search Radius'.tr,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                skillName,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close, color: Colors.grey, size: 22),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Radius Display Card
              Obx(() => Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary.withValues(alpha: 0.08),
                          AppColors.primary.withValues(alpha: 0.03),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              toBnDigits(selectedKm.value),
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                                height: 1,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'km'.tr,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isBn
                              ? "আপনার অবস্থান থেকে ${toBnDigits(selectedKm.value)} কিমি এলাকার মধ্যে সেবাদাতা খোঁজা হবে"
                              : "Searching providers within ${selectedKm.value} km of your location",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 14),

              // Slider (Discrete integer range 1 to 5, divisions: 4, no fraction!)
              Obx(() => SliderTheme(
                    data: SliderTheme.of(Get.context!).copyWith(
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: Colors.grey.shade200,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withValues(alpha: 0.2),
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 11),
                      valueIndicatorColor: AppColors.primary,
                      valueIndicatorTextStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    child: Slider(
                      value: selectedKm.value.toDouble(),
                      min: 1.0,
                      max: 5.0,
                      divisions: 4, // 1, 2, 3, 4, 5
                      label: "${toBnDigits(selectedKm.value)} ${'km'.tr}",
                      onChanged: (val) {
                        selectedKm.value = val.round();
                      },
                    ),
                  )),

              // 5 Clickable Pills (1, 2, 3, 4, 5 km)
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [1, 2, 3, 4, 5].map((km) {
                      final isSelected = selectedKm.value == km;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            selectedKm.value = km;
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.grey.shade300,
                                width: isSelected ? 1.5 : 1.0,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.primary.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                "${toBnDigits(km)} ${'km'.tr}",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  )),

              const SizedBox(height: 20),

              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    searchRadiusKm.value = selectedKm.value;
                    Get.back();
                    showLocationSelectionSheet(skillId, skillName);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Next (Select Location)'.tr,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  /// Show dialog / bottom sheet asking Seeker where they want the service:
 
  void showLocationSelectionSheet(int skillId, String skillName) async {
    await loadHomeLocationData();

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: SafeArea(
          bottom: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title & Subtitle
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.place_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'choose_search_location'.tr,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 6,
                          children: [
                            Text(
                              '$skillName - ${'where_do_you_need_service'.tr}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "${toBnDigits(searchRadiusKm.value)} ${'km'.tr}",
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Option 1: Current GPS Location Card
              InkWell(
                onTap: () {
                  Get.back();
                  searchProviders(skillId, useHomeLocation: false);
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: selectedLocationMode.value == 'current'
                        ? Colors.blue.shade50.withValues(alpha: 0.6)
                        : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selectedLocationMode.value == 'current'
                          ? Colors.blue.shade600
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.my_location_rounded,
                          color: Colors.blue.shade800,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'current_gps_location'.tr,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'search_near_current_location'.tr,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Option 2: Saved Home Address Card
              Obx(() {
                final hasHome = homeAddress.value.isNotEmpty;
                return InkWell(
                  onTap: () {
                    Get.back();
                    if (!hasHome && homeLatitude.value == 0.0) {
                      showCustomSnackBar('home_location_not_found'.tr, isError: true);
                      searchProviders(skillId, useHomeLocation: false);
                    } else {
                      searchProviders(skillId, useHomeLocation: true);
                    }
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: selectedLocationMode.value == 'home'
                          ? Colors.teal.shade50
                          : Colors.teal.shade50.withValues(alpha:0.4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selectedLocationMode.value == 'home'
                            ? AppColors.primary
                            : Colors.teal.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.home_work_rounded,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 6,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    'saved_home_address'.tr,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.teal.shade100,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      'home_service_recommended'.tr,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.teal.shade900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hasHome
                                    ? homeAddress.value
                                    : 'home_location_not_found'.tr,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: hasHome
                                      ? Colors.black87
                                      : Colors.red.shade600,
                                  fontWeight: hasHome
                                      ? FontWeight.w500
                                      : FontWeight.normal,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> searchProviders(
    int skillId, {
    bool useHomeLocation = false,
    int? radiusKm,
    int? page,
    int? pageSize,
  }) async {
    currentSkillId.value = skillId;
    isLoadingProviders.value = true;
    if (radiusKm != null) searchRadiusKm.value = radiusKm;
    if (pageSize != null) searchPageSize.value = pageSize;
    currentSearchPage.value = page ?? 1;
    totalSearchPages.value = 1;
    hasNextSearchPage.value = false;

    double targetLat = 0.0;
    double targetLng = 0.0;

    if (useHomeLocation) {
      await loadHomeLocationData();

      // If lat/lng missing, try geocoding homeAddress
      if ((homeLatitude.value == 0.0 || homeLongitude.value == 0.0) &&
          homeAddress.value.isNotEmpty) {
        await _geocodeHomeAddress(homeAddress.value);
      }

      if (homeLatitude.value != 0.0 && homeLongitude.value != 0.0) {
        targetLat = homeLatitude.value;
        targetLng = homeLongitude.value;
        selectedLocationMode.value = 'home';
        selectedLocationAddress.value = homeAddress.value.isNotEmpty
            ? homeAddress.value
            : 'Saved Home Address'.tr;
      } else {
        showCustomSnackBar('home_location_not_found'.tr, isError: true);
        useHomeLocation = false;
      }
    }

    if (!useHomeLocation) {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        isLoadingProviders.value = false;
        showCustomSnackBar("Location services are disabled.", isError: true);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          isLoadingProviders.value = false;
          showCustomSnackBar("Location permissions are denied", isError: true);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        isLoadingProviders.value = false;
        showCustomSnackBar(
          "Location permissions are permanently denied, we cannot request permissions.",
          isError: true,
        );
        return;
      }

      try {
        Position position = await Geolocator.getCurrentPosition();
        targetLat = position.latitude;
        targetLng = position.longitude;
        selectedLocationMode.value = 'current';
        selectedLocationAddress.value = 'Current Location'.tr;
      } catch (e) {
        isLoadingProviders.value = false;
        showCustomSnackBar("Failed to get current GPS location", isError: true);
        return;
      }
    }

    seekerLat = targetLat;
    seekerLng = targetLng;
    initialPosition.value = LatLng(targetLat, targetLng);

    // Update map camera
    if (customInfoWindowController.googleMapController != null) {
      customInfoWindowController.googleMapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(targetLat, targetLng), 14),
      );
    }

    try {
      final response = await ApiClient.getData(
        "${ApiUrl.searchProviders}?skill_id=$skillId&seeker_lat=$targetLat&seeker_lng=$targetLng&search_radius_km=${searchRadiusKm.value}&page=${currentSearchPage.value}&page_size=${searchPageSize.value}",
      );
      isLoadingProviders.value = false;

      if (response.statusCode == 200) {
        List data = response.body['items'] ?? response.body['providers'] ?? [];
        providers.value = data.map((e) => ProviderModel.fromJson(e)).toList();

        currentSearchPage.value = response.body['page'] ?? 1;
        totalSearchPages.value = response.body['total_pages'] ?? 1;
        hasNextSearchPage.value = response.body['has_next'] ?? false;

        _updateMarkers(LatLng(targetLat, targetLng), isHome: useHomeLocation);

        if (providers.isEmpty && response.body['warning'] != null) {
          String warning = response.body['warning'].toString();
          showCustomSnackBar(warning, isError: false);
        }

        // Check active booking status whenever search runs
        await checkActiveBooking();

        // Refresh camera slightly to trigger pin layout
        Future.delayed(const Duration(milliseconds: 200), () {
          if (customInfoWindowController.googleMapController != null) {
            customInfoWindowController.googleMapController!.animateCamera(
              CameraUpdate.newLatLng(LatLng(targetLat, targetLng)),
            );
          }
        });
      }
    } catch (e) {
      isLoadingProviders.value = false;
      debugPrint("Search providers error: $e");
    }
  }

  /// Load next page of providers when seeker scrolls to bottom
  Future<void> loadMoreProviders() async {
    if (isLoadingMoreProviders.value ||
        isLoadingProviders.value ||
        !hasNextSearchPage.value) {
      return;
    }

    final nextPage = currentSearchPage.value + 1;
    if (nextPage > totalSearchPages.value) {
      hasNextSearchPage.value = false;
      return;
    }

    isLoadingMoreProviders.value = true;
    try {
      final response = await ApiClient.getData(
        "${ApiUrl.searchProviders}?skill_id=${currentSkillId.value}&seeker_lat=$seekerLat&seeker_lng=$seekerLng&search_radius_km=${searchRadiusKm.value}&page=$nextPage&page_size=${searchPageSize.value}",
      );

      if (response.statusCode == 200 && response.body != null) {
        List data = response.body['items'] ?? response.body['providers'] ?? [];
        final newProviders =
            data.map((e) => ProviderModel.fromJson(e)).toList();

        // Avoid adding duplicate providers if any
        final existingIds = providers.map((p) => p.userId).toSet();
        for (var p in newProviders) {
          if (!existingIds.contains(p.userId)) {
            providers.add(p);
            existingIds.add(p.userId);
          }
        }

        currentSearchPage.value = response.body['page'] ?? nextPage;
        totalSearchPages.value =
            response.body['total_pages'] ?? totalSearchPages.value;
        hasNextSearchPage.value = response.body['has_next'] ??
            (currentSearchPage.value < totalSearchPages.value);

        // Update map markers with newly added providers as well
        _updateMarkers(
          LatLng(seekerLat, seekerLng),
          isHome: selectedLocationMode.value == 'home',
        );
      }
    } catch (e) {
      debugPrint("Error loading more providers: $e");
    } finally {
      isLoadingMoreProviders.value = false;
    }
  }

  Future<void> _geocodeHomeAddress(String address) async {
    try {
      if (ApiUrl.mapKey.isNotEmpty) {
        final uri = Uri.https(
          'maps.googleapis.com',
          '/maps/api/geocode/json',
          {
            'address': address,
            'key': ApiUrl.mapKey,
          },
        );
        final res = await http.get(uri).timeout(const Duration(seconds: 5));
        if (res.statusCode == 200) {
          final data = json.decode(res.body);
          if (data['status'] == 'OK' &&
              data['results'] != null &&
              (data['results'] as List).isNotEmpty) {
            final loc = data['results'][0]['geometry']?['location'];
            if (loc != null) {
              double lat = double.tryParse(loc['lat'].toString()) ?? 0.0;
              double lng = double.tryParse(loc['lng'].toString()) ?? 0.0;
              if (lat != 0.0 && lng != 0.0) {
                homeLatitude.value = lat;
                homeLongitude.value = lng;
                await SharePrefsHelper.setString("seeker_home_lat", lat.toString());
                await SharePrefsHelper.setString("seeker_home_lng", lng.toString());
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Geocoding home address error: $e");
    }
  }

  void _updateMarkers(LatLng centerPosition, {bool isHome = false}) {
    var newMarkers = <Marker>{};

    // Center Search Marker (Home / GPS)
    newMarkers.add(
      Marker(
        markerId: const MarkerId('search_center_point'),
        position: centerPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          isHome ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueAzure,
        ),
        infoWindow: InfoWindow(
          title: isHome ? 'Home Location'.tr : 'Current Location'.tr,
          snippet: selectedLocationAddress.value,
        ),
      ),
    );

    for (int i = 0; i < providers.length; i++) {
      var provider = providers[i];
      double lat = provider.latitude != 0 ? provider.latitude : 0;
      double lng = provider.longitude != 0 ? provider.longitude : 0;

      if (lat == 0 || lng == 0) {
        // Distribute markers in a circle around center based on distanceKm
        final double angle =
            (2 * math.pi / (providers.isEmpty ? 1 : providers.length)) * i;
        final double distKm =
            provider.distanceKm > 0 ? provider.distanceKm : (0.5 + (i * 0.3));
        final double dLat = (distKm / 111.0) * math.cos(angle);
        final double dLng = (distKm /
                (111.0 * math.cos(centerPosition.latitude * math.pi / 180))) *
            math.sin(angle);
        lat = centerPosition.latitude + dLat;
        lng = centerPosition.longitude + dLng;
      }

      newMarkers.add(
        Marker(
          markerId: MarkerId(
            provider.userId.isNotEmpty ? provider.userId : 'provider_$i',
          ),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          consumeTapEvents: true, // Non-clickable marker: only displays on map
        ),
      );
    }
    markers.assignAll(newMarkers);
  }

  /// 1. Request to Call: Initiate booking with backend and get phone number
  Future<void> initiateBooking(ProviderModel provider) async {
    if (isInitiatingBooking.value) return;
    isInitiatingBooking.value = true;

    try {
      if (seekerLat == 0.0 || seekerLng == 0.0) {
        try {
          Position pos = await Geolocator.getCurrentPosition();
          seekerLat = pos.latitude;
          seekerLng = pos.longitude;
        } catch (_) {
          seekerLat = initialPosition.value.latitude;
          seekerLng = initialPosition.value.longitude;
        }
      }

      int skillIdToSend = currentSkillId.value;
      if (skillIdToSend == 0 && skills.isNotEmpty) {
        skillIdToSend = skills.first.id;
      }
      if (skillIdToSend == 0) {
        skillIdToSend = 1;
      }

      final Map<String, dynamic> requestBody = {
        "provider_id": provider.userId,
        "skill_id": skillIdToSend,
        "latitude": seekerLat,
        "longitude": seekerLng,
      };

      final response = await ApiClient.postData(
        ApiUrl.initiateBooking,
        requestBody,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.body;
        String phone = data['provider_phone'] ?? provider.phoneEn ?? '';
        String providerName = data['provider_name'] ?? provider.name;
        String bookingId = data['booking_id']?.toString() ?? '';

        // Update active booking status
        hasActiveBooking.value = true;
        activeBookingData.value = {
          'booking_id': bookingId,
          'provider_id': provider.userId,
          'provider_name': providerName,
          'provider_phone': phone,
          'status': 'initiated',
          'created_at': DateTime.now().toIso8601String(),
        };

        // Show Call Dialog with provider details
        _showCallProviderDialog(
          providerName: providerName,
          phone: phone,
          bookingId: bookingId,
        );
      } else {
        String msg = "Could not initiate booking".tr;
        if (response.body is Map && response.body['detail'] != null) {
          msg = response.body['detail'].toString();
        }
        showCustomSnackBar(msg);
        // Refresh active booking state in case one was already active
        await checkActiveBooking();
      }
    } catch (e) {
      debugPrint("Error initiating booking: $e");
      showCustomSnackBar("Something went wrong".tr);
    } finally {
      isInitiatingBooking.value = false;
    }
  }

  /// Show popup with provider's contact number and Call button
  void _showCallProviderDialog({
    required String providerName,
    required String phone,
    required String bookingId,
  }) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.phone_in_talk, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Contact Provider'.tr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'call_provider_confirm_msg'.trParams({'name': providerName}),
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.phone, color: AppColors.primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      phone.isNotEmpty ? phone : "Number not available".tr,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // close dialog
              checkActiveBooking();
            },
            child: Text('Close'.tr, style: const TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () async {
              Get.back(); // close dialog
              if (phone.isNotEmpty) {
                final Uri launchUri = Uri(scheme: 'tel', path: phone);
                if (await canLaunchUrl(launchUri)) {
                  await launchUrl(launchUri);
                } else {
                  showCustomSnackBar('Could not launch phone app'.tr);
                }
              }
              // When user returns to app, reload last active initiated booking
              await checkActiveBooking();
            },
            icon: const Icon(Icons.call, color: Colors.white, size: 18),
            label: Text(
              'Call Now'.tr,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  /// 2. Cancel Booking
  Future<void> cancelBooking(String bookingId) async {
    if (isCancellingBooking.value || isConfirmingBooking.value) return;
    isCancellingBooking.value = true;

    try {
      final response = await ApiClient.patchData(
        ApiUrl.respondBooking(bookingId),
        {"hired": false},
      );

      if (response.statusCode == 200) {
        showCustomSnackBar("Booking cancelled successfully".tr, isError: false);
        hasActiveBooking.value = false;
        activeBookingData.value = null;
        Get.until((route) => route.isFirst); // Return to home screen
      } else {
        String msg = "Could not cancel booking".tr;
        if (response.body is Map && response.body['detail'] != null) {
          msg = response.body['detail'].toString();
        }
        showCustomSnackBar(msg);
      }
    } catch (e) {
      debugPrint("Error cancelling booking: $e");
      showCustomSnackBar("Something went wrong".tr);
    } finally {
      isCancellingBooking.value = false;
      await checkActiveBooking();
    }
  }

  /// 3. Show Date & Time Schedule Picker Dialog / Bottom Sheet before confirming hire
  void showWorkSchedulePicker(String bookingId, {String providerName = ''}) {
    // Default schedule: 1 hour from now, rounded to next 15 minutes
    DateTime initial = DateTime.now().add(const Duration(hours: 1));
    initial = DateTime(
      initial.year,
      initial.month,
      initial.day,
      initial.hour,
      (initial.minute / 15).ceil() * 15 % 60,
    );

    var selectedDate = Rx<DateTime>(initial);
    var selectedTime = Rx<TimeOfDay>(
      TimeOfDay(hour: initial.hour, minute: initial.minute),
    );
    var errorMessage = ''.obs;
    var selectedPreset = '1_hour'.obs;

    DateTime getCombinedDateTime() {
      final date = selectedDate.value;
      final time = selectedTime.value;
      return DateTime(date.year, date.month, date.day, time.hour, time.minute);
    }

    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: SafeArea(
          bottom: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top drag pill
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'select_work_schedule'.tr,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            providerName.isNotEmpty
                                ? '${'work_schedule_subtitle_provider'.tr}: $providerName'
                                : 'work_schedule_subtitle'.tr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Quick Presets Chips
                Text(
                  'quick_options'.tr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(
                  () => SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildPresetChip(
                          label: 'in_1_hour'.tr,
                          isSelected: selectedPreset.value == '1_hour',
                          onTap: () {
                            selectedPreset.value = '1_hour';
                            final dt = DateTime.now().add(const Duration(hours: 1));
                            selectedDate.value = dt;
                            selectedTime.value = TimeOfDay(hour: dt.hour, minute: dt.minute);
                            errorMessage.value = '';
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildPresetChip(
                          label: 'in_2_hours'.tr,
                          isSelected: selectedPreset.value == '2_hours',
                          onTap: () {
                            selectedPreset.value = '2_hours';
                            final dt = DateTime.now().add(const Duration(hours: 2));
                            selectedDate.value = dt;
                            selectedTime.value = TimeOfDay(hour: dt.hour, minute: dt.minute);
                            errorMessage.value = '';
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildPresetChip(
                          label: 'tomorrow_morning'.tr,
                          isSelected: selectedPreset.value == 'tomorrow_morning',
                          onTap: () {
                            selectedPreset.value = 'tomorrow_morning';
                            final dt = DateTime.now().add(const Duration(days: 1));
                            selectedDate.value = dt;
                            selectedTime.value = const TimeOfDay(hour: 10, minute: 0);
                            errorMessage.value = '';
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildPresetChip(
                          label: 'tomorrow_afternoon'.tr,
                          isSelected: selectedPreset.value == 'tomorrow_afternoon',
                          onTap: () {
                            selectedPreset.value = 'tomorrow_afternoon';
                            final dt = DateTime.now().add(const Duration(days: 1));
                            selectedDate.value = dt;
                            selectedTime.value = const TimeOfDay(hour: 15, minute: 0);
                            errorMessage.value = '';
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Date & Time Picker Cards
                Row(
                  children: [
                    // Date Box
                    Expanded(
                      child: Obx(() {
                        final dateStr = DateFormat('EEE, dd MMM yyyy').format(selectedDate.value);
                        return InkWell(
                          onTap: () async {
                            final now = DateTime.now();
                            final picked = await showDatePicker(
                              context: Get.context!,
                              initialDate: selectedDate.value.isBefore(now)
                                  ? now
                                  : selectedDate.value,
                              firstDate: now,
                              lastDate: now.add(const Duration(days: 60)),
                            );
                            if (picked != null) {
                              selectedDate.value = picked;
                              selectedPreset.value = '';
                              errorMessage.value = '';
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_month, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      'date'.tr,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  dateStr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(width: 12),

                    // Time Box
                    Expanded(
                      child: Obx(() {
                        final time = selectedTime.value;
                        final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
                        final minute = time.minute.toString().padLeft(2, '0');
                        final period = time.period == DayPeriod.am ? 'AM' : 'PM';
                        final timeStr = "$hour:$minute $period";

                        return InkWell(
                          onTap: () async {
                            final picked = await showTimePicker(
                              context: Get.context!,
                              initialTime: selectedTime.value,
                            );
                            if (picked != null) {
                              selectedTime.value = picked;
                              selectedPreset.value = '';
                              errorMessage.value = '';
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Text(
                                      'time'.tr,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  timeStr,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),

                // Error message (if selected in the past)
                Obx(() {
                  if (errorMessage.value.isEmpty) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      errorMessage.value,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Cancel'.tr),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Obx(
                        () => ElevatedButton(
                          onPressed: isConfirmingBooking.value
                              ? null
                              : () {
                                  final combined = getCombinedDateTime();
                                  if (combined.isBefore(DateTime.now().add(const Duration(minutes: 5)))) {
                                    errorMessage.value = 'work_schedule_must_be_future'.tr;
                                    return;
                                  }
                                  final isoString = combined.toUtc().toIso8601String();
                                  confirmHireBooking(bookingId, workSchedule: isoString);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                          ),
                          child: isConfirmingBooking.value
                              ? const SizedBox(
                                  height: 18,
                                  width: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Confirm & Hire'.tr,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildPresetChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.28),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(
                Icons.check_circle_rounded,
                size: 15,
                color: Colors.white,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 4. Confirm Hire Booking with ISO 8601 UTC work_schedule
  Future<void> confirmHireBooking(String bookingId, {String? workSchedule}) async {
    // If not provided, fallback to 2 hours from now in UTC
    final scheduleToSend = workSchedule ??
        DateTime.now().add(const Duration(hours: 2)).toUtc().toIso8601String();

    if (isCancellingBooking.value || isConfirmingBooking.value) return;
    isConfirmingBooking.value = true;

    try {
      final response = await ApiClient.patchData(
        ApiUrl.respondBooking(bookingId),
        {
          "hired": true,
          "work_schedule": scheduleToSend,
        },
      );

      if (response.statusCode == 200) {
        // If bottom sheet was open, close it
        if (Get.isBottomSheetOpen == true) {
          Get.back();
        }
        showCustomSnackBar("Booking confirmed successfully!".tr, isError: false);
        hasActiveBooking.value = false;
        activeBookingData.value = null;
        Get.until((route) => route.isFirst); // Return to home screen
      } else {
        String msg = "Could not confirm booking".tr;
        if (response.body is Map && response.body['detail'] != null) {
          msg = response.body['detail'].toString();
        }
        showCustomSnackBar(msg);
      }
    } catch (e) {
      debugPrint("Error confirming booking: $e");
      showCustomSnackBar("Something went wrong".tr);
    } finally {
      isConfirmingBooking.value = false;
      await checkActiveBooking();
    }
  }
}
