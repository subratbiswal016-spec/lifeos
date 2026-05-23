import 'package:flutter/material.dart';

class MockTestScreen extends StatelessWidget {
  const MockTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mock Test Simulator')),
      body: const Center(child: Text('Mock Test Interface Coming Soon')),
    );
  }
}
