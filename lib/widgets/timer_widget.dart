import 'package:flutter/material.dart';

class TimerWidget extends StatelessWidget {
  final int timeLeft;
  final int totalTime;

  const TimerWidget({
    super.key,
    required this.timeLeft,
    required this.totalTime,
  });

  Color _getColor(BuildContext context) {
    if (timeLeft > totalTime * 0.5) {
      return Theme.of(context).colorScheme.primary;
    } else if (timeLeft > totalTime * 0.25) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor(context);

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: CircularProgressIndicator(
            value: timeLeft / totalTime,
            strokeWidth: 6,
            color: color,
            backgroundColor: Theme.of(context).colorScheme.surface,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$timeLeft',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              'sek',
              style: TextStyle(
                fontSize: 10,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}