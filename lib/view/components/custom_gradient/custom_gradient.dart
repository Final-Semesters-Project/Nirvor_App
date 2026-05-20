import 'package:flutter/material.dart';

class CustomGradient extends StatelessWidget {
  final Widget child;
  final Color color1;
  final Color color2;

  const CustomGradient({
    super.key,
    required this.child,
    this.color1 = Colors.white,
    // this.color2 = const Color(0xFF2DBE60),
    this.color2 = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomCenter,
          colors: [color1, color2],
        ),
      ),
      child: SafeArea(bottom: true, top: false, child: child),
    );
  }
}
