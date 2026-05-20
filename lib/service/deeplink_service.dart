//
// import 'dart:async';
// import 'dart:developer';
// import 'package:app_links/app_links.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
//
// import '../consultant_dashboard_screen/screens/host_part/social/social_screen/deep_link_post_screen.dart';
//
// /// Handles only link detection and navigation
// class DeepLinkService {
//   static final DeepLinkService _instance = DeepLinkService._internal();
//   factory DeepLinkService() => _instance;
//   DeepLinkService._internal();
//
//   final AppLinks _appLinks = AppLinks();
//   StreamSubscription<Uri>? _linkSubscription;
//
//   /// Initialize deep links
//   Future<void> initDeepLinks() async {
//     // Cold start
//     final initialLink = await _appLinks.getInitialLink();
//     if (initialLink != null) {
//       _handleLink(initialLink);
//     }
//
//     // Foreground/background
//     _linkSubscription = _appLinks.uriLinkStream.listen(
//           (uri) => _handleLink(uri),
//       onError: (err) => debugPrint("DeepLink error: $err"),
//     );
//   }
//
//   void _handleLink(Uri uri) {
//         // Detect type of link
//     log(uri.toString());
//     if (uri.path.startsWith("/post/")) {
//       final postId = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
//       if (postId != null) {
//         //route
//         Get.to(PostScreen(postId: postId,));
//
//       }
//     }
//   }
//
//   void dispose() {
//     _linkSubscription?.cancel();
//   }
// }