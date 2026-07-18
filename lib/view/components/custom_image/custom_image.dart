import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

enum ImageType {
  png,
  svg,
}

class CustomImage extends StatefulWidget {
  final String imageSrc;
  final Color? imageColor;
  final double? height;
  final double? scale;
  final double? width;
  final double? sizeWidth;
  final ImageType imageType;
  final BoxFit? fit;
  final double horizontal;
  final double vertical;
  final BoxFit? boxFit;

  const CustomImage({
    required this.imageSrc,
    this.imageColor,
    this.sizeWidth,
    this.imageType = ImageType.svg,
    super.key,
    this.fit,
    this.scale,
    this.horizontal = 0.0,
    this.vertical = 0.0,
    this.boxFit,
    this.height,
    this.width,
  });

  @override
  State<CustomImage> createState() => _CustomImageState();
}

class _CustomImageState extends State<CustomImage> {
  @override
  Widget build(BuildContext context) { 
    Widget imageWidget = const SizedBox.shrink();
    
    if (widget.imageSrc.startsWith('http://') || widget.imageSrc.startsWith('https://')) {
      if (widget.imageSrc.contains('.svg')) {
        imageWidget = SvgPicture.network(
          widget.imageSrc,
          // ignore: deprecated_member_use
          color: widget.imageColor,
          height: widget.height,
          width: widget.width,
          fit: widget.boxFit ?? BoxFit.cover,
        );
      } else {
        imageWidget = Image.network(
          widget.imageSrc,
          color: widget.imageColor,
          height: widget.height,
          width: widget.width,
          fit: widget.fit ?? widget.boxFit ?? BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 24),
        );
      }
    } else if (widget.imageSrc.endsWith('svg')) {
      imageWidget = SvgPicture.asset(
        widget.imageSrc,
        // ignore: deprecated_member_use
        color: widget.imageColor,
        height: widget.height,
        width: widget.width,
        fit: widget.boxFit ?? BoxFit.cover,
      );
    } else if (widget.imageSrc.endsWith('png') || widget.imageSrc.endsWith('jpg') || widget.imageSrc.endsWith('jpeg')) {
      imageWidget = Image.asset(
        fit: widget.fit,
        widget.imageSrc,
        color: widget.imageColor,
        height: widget.height,
        width: widget.width,
        scale: widget.scale ?? 1,
      );
    } else {
      imageWidget = Image.asset(
        fit: widget.fit,
        widget.imageSrc,
        color: widget.imageColor,
        height: widget.height,
        width: widget.width,
        scale: widget.scale ?? 1,
        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: widget.horizontal, vertical: widget.vertical),
      width: widget.sizeWidth,
      child: imageWidget,
    );
  }
}
