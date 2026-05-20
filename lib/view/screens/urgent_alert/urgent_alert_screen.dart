import 'package:flutter/material.dart';

class UrgentAlertScreen extends StatelessWidget {
  const UrgentAlertScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Urgent Alert')),
      body: const Center(child: Text('Urgent Alert Screen')),
    );
  }
}
