import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../../utils/ToastMsg/toast_message.dart';
import '../../../../utils/app_colors/app_colors.dart';
import '../../../components/custom_button/custom_button.dart';
import '../controller/auth_controller.dart';

class MapLocationPickerScreen extends StatefulWidget {
  const MapLocationPickerScreen({super.key});

  @override
  State<MapLocationPickerScreen> createState() => _MapLocationPickerScreenState();
}

class _MapLocationPickerScreenState extends State<MapLocationPickerScreen> {
  final AuthController authController = Get.find<AuthController>();
  GoogleMapController? _mapController;

  late LatLng _currentLatLng;
  String _currentAddress = '';
  bool _isLoadingAddress = false;
  bool _isMoving = false;
  Timer? _debounceTimer;

  static const LatLng _dhakaDefault = LatLng(23.8103, 90.4125);

  @override
  void initState() {
    super.initState();
    if (authController.latitude.value != 0.0 && authController.longitude.value != 0.0) {
      _currentLatLng = LatLng(authController.latitude.value, authController.longitude.value);
      _currentAddress = authController.locationAddress.value;
    } else {
      _currentLatLng = _dhakaDefault;
      _determineInitialPosition();
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _determineInitialPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _reverseGeocode(_currentLatLng);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 4),
        );
        final userLatLng = LatLng(position.latitude, position.longitude);
        if (mounted) {
          setState(() {
            _currentLatLng = userLatLng;
          });
          _mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 16));
          _reverseGeocode(userLatLng);
        }
      } else {
        _reverseGeocode(_currentLatLng);
      }
    } catch (e) {
      debugPrint("Error determining initial position: $e");
      _reverseGeocode(_currentLatLng);
    }
  }

  void _onCameraMove(CameraPosition position) {
    _currentLatLng = position.target;
    if (!_isMoving) {
      setState(() {
        _isMoving = true;
      });
    }
  }

  void _onCameraIdle() {
    setState(() {
      _isMoving = false;
    });
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _reverseGeocode(_currentLatLng);
    });
  }

  Future<void> _reverseGeocode(LatLng target) async {
    if (!mounted) return;
    setState(() {
      _isLoadingAddress = true;
    });

    final address = await authController.reverseGeocode(target.latitude, target.longitude);

    if (mounted) {
      setState(() {
        _currentAddress = address ??
            "Selected Location (${target.latitude.toStringAsFixed(4)}, ${target.longitude.toStringAsFixed(4)})";
        _isLoadingAddress = false;
      });
    }
  }

  Future<void> _goToCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showCustomSnackBar("Location services are disabled".tr, isError: true);
        return;
      }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          showCustomSnackBar("Location permission denied".tr, isError: true);
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        showCustomSnackBar("Location permission permanently denied".tr, isError: true);
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 4),
      );
      final userLatLng = LatLng(position.latitude, position.longitude);
      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(userLatLng, 16));
    } catch (e) {
      debugPrint("Error fetching current position: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLatLng,
              zoom: 16,
            ),
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            onMapCreated: (controller) {
              _mapController = controller;
              if (_currentAddress.isEmpty) {
                _reverseGeocode(_currentLatLng);
              }
            },
            onCameraMove: _onCameraMove,
            onCameraIdle: _onCameraIdle,
            onTap: (LatLng position) {
              _mapController?.animateCamera(CameraUpdate.newLatLng(position));
            },
          ),

          // 2. Fixed Center Marker Pin with Tip Aligned to Center (Wrapped in IgnorePointer so mouse gestures pass through to map)
          IgnorePointer(
            ignoring: true,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 38.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _isMoving ? Colors.black87 : AppColors.primary,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isMoving ? Icons.pan_tool_alt : Icons.store_mall_directory_outlined,
                            color: Colors.white,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isMoving ? "Moving...".tr : "Pin Location".tr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Icon(
                      Icons.location_pin,
                      size: 46,
                      color: AppColors.primary,
                    ),
                    Container(
                      width: 8,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Top Address Info Box
          SafeArea(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 15,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Selected Location".tr,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        if (_isLoadingAddress)
                          Row(
                            children: [
                              const SizedBox(
                                width: 13,
                                height: 13,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Fetching address...".tr,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          )
                        else
                          Text(
                            _currentAddress.isNotEmpty
                                ? _currentAddress
                                : "Move the map to place the pin on your shop or home".tr,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 4. Zoom Controls Floating Buttons (Easy navigation in emulator/mouse)
          Positioned(
            bottom: 145,
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'map_picker_zoom_in',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 4,
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomIn());
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 8),
                FloatingActionButton.small(
                  heroTag: 'map_picker_zoom_out',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 4,
                  onPressed: () {
                    _mapController?.animateCamera(CameraUpdate.zoomOut());
                  },
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),

          // 5. My Location (GPS) Floating Button
          Positioned(
            bottom: 90,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'map_picker_gps_btn',
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              elevation: 4,
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location),
            ),
          ),

          // 6. Bottom Confirm Location Button
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              top: false,
              child: CustomButton(
                onTap: () {
                  if (_currentAddress.isEmpty) {
                    showCustomSnackBar("Please select a valid location".tr, isError: true);
                    return;
                  }
                  authController.latitude.value = _currentLatLng.latitude;
                  authController.longitude.value = _currentLatLng.longitude;
                  authController.locationAddress.value = _currentAddress;
                  authController.locationController.text = _currentAddress;
                  authController.locationSuggestions.clear();
                  Get.back();
                  showCustomSnackBar("Location selected successfully".tr, isError: false);
                },
                title: "Confirm Location".tr,
                fillColor: AppColors.primary,
                textColor: Colors.white,
                fontSize: 16.sp,
                borderRadius: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

