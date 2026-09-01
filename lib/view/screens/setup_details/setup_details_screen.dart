import 'package:flutter/material.dart';

class SetupDetailsScreen extends StatelessWidget {
  const SetupDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Details')),
      body: const Center(child: Text('Setup Details Screen')),
    );
  }
}
