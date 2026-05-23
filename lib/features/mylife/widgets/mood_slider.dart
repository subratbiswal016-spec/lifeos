import 'package:flutter/material.dart';

class MoodSlider extends StatefulWidget {
  final ValueChanged<double> onChanged;
  final double value;

  const MoodSlider({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  State<MoodSlider> createState() => _MoodSliderState();
}

class _MoodSliderState extends State<MoodSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _getMoodEmoji(_currentValue),
          style: TextStyle(fontSize: 40 + (_currentValue * 10)),
        ),
        const SizedBox(height: 16),
        Slider(
          value: _currentValue,
          min: 0,
          max: 4,
          divisions: 4,
          activeColor: const Color(0xFFFF6B35),
          inactiveColor: Colors.grey.withOpacity(0.3),
          onChanged: (val) {
            setState(() => _currentValue = val);
            widget.onChanged(val);
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('Awful', style: TextStyle(color: Colors.grey)),
            Text('Amazing', style: TextStyle(color: Colors.grey)),
          ],
        )
      ],
    );
  }

  String _getMoodEmoji(double val) {
    if (val < 1) return '😭';
    if (val < 2) return '🙁';
    if (val < 3) return '😐';
    if (val < 4) return '🙂';
    return '🤩';
  }
}
