import 'package:flutter/material.dart';

class DesignSystemScreen extends StatelessWidget {
  const DesignSystemScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design System'),
      ),
      body: Center(
        child: Text(
          'Design System Screen',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
      ),
    );
  }
}
