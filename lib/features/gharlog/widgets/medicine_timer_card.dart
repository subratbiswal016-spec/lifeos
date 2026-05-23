import 'package:flutter/material.dart';

class MedicineTimerCard extends StatelessWidget {
  const MedicineTimerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Next dose in:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text('02h 15m', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }
}
