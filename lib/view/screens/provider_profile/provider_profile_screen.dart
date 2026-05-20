import 'package:flutter/material.dart';

class ProviderProfileScreen extends StatelessWidget {
  const ProviderProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Provider Profile')),
      body: const Center(child: Text('Provider Profile Screen')),
    );
  }
}
