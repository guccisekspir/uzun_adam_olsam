import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ValueIndicator extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const ValueIndicator({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: color,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              value.toString(),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _getValueColor(value),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 60,
          height: 5,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2.5),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(_getValueColor(value)),
            ),
          ),
        ),
      ],
    );
  }

  Color _getValueColor(int value) {
    if (value <= 20) {
      return Colors.red;
    } else if (value <= 40) {
      return Colors.orange;
    } else if (value <= 60) {
      return Colors.yellow[700]!;
    } else if (value <= 80) {
      return Colors.lightGreen;
    } else {
      return Colors.green;
    }
  }
}
