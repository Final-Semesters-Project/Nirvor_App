import 'package:flutter/material.dart';

class HomeSeekerScreen extends StatelessWidget {
  const HomeSeekerScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home - Seeker')),
      body: const Center(child: Text('Home Seeker Screen')),
    );
  }
}
