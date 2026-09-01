import 'package:flutter/material.dart';

class IncomingBookingsScreen extends StatelessWidget {
  const IncomingBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Bookings')),
      body: const Center(child: Text('Incoming Bookings Screen')),
    );
  }
}
