import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/neo_ottoman_theme.dart';

class ValueIndicator extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  final int? previousValue;
  final bool showAnimation;

  const ValueIndicator({
    Key? key,
    required this.label,
    required this.value,
    required this.color,
    this.previousValue,
    this.showAnimation = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Label with Ottoman-style decoration
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: NeoOttomanTheme.gold,
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: NeoOttomanTheme.ivory,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 6),
        
        // Value indicator with Ottoman medallion style
        Stack(
          alignment: Alignment.center,
          children: [
            // Ottoman medallion background
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    NeoOttomanTheme.ivory,
                    const Color(0xFFF5F5DC),
                  ],
                ),
                border: Border.all(
                  color: NeoOttomanTheme.gold,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withOpacity(0.7),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      value.toString(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: _getValueColor(value),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            
            // Value change indicator
            if (showAnimation && previousValue != null && previousValue != value)
              Positioned(
                right: 0,
                top: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: value > previousValue! ? Colors.green.shade700 : Colors.red.shade700,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: NeoOttomanTheme.gold,
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    value > previousValue! ? '+${value - previousValue!}' : '${value - previousValue!}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
        
        const SizedBox(height: 6),
        
        // Progress bar with Ottoman-style
        Container(
          width: 70,
          height: 8,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: NeoOttomanTheme.gold.withOpacity(0.7),
              width: 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
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
      return Colors.red.shade700;
    } else if (value <= 40) {
      return Colors.orange.shade700;
    } else if (value <= 60) {
      return Colors.amber.shade700;
    } else if (value <= 80) {
      return Colors.lightGreen.shade700;
    } else {
      return Colors.green.shade700;
    }
  }
}
