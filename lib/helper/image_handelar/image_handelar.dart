import '../../service/api_url.dart';
import '../../utils/app_images/app_images.dart';

class ImageHandler {
  static String imagesHandle(String? url) {
    if (url == null || url.isEmpty) {
      return AppImages.loginImg;
    }

    if (url.startsWith('http')) {
      return url;
    } else {
      return ApiUrl.imageUrl + url;
    }
  }
}
