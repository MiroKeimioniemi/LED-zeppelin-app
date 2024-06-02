import 'dart:math';

import 'package:flutter/material.dart';

class GradientBackground extends StatelessWidget {
  const GradientBackground(
      {super.key,
      required this.color,
      required this.brightness,
      required this.isOn});
  final Color color;
  final double brightness;
  final bool isOn;

  BoxDecoration _simpleBox(List<Color> colors, List<double> stops) {
    List<Color> gradientColors;
    if (isOn) {
      gradientColors = [colors[0], colors[1]];
    } else {
      gradientColors = [const Color.fromARGB(255, 55, 55, 55), Colors.black];
    }

    return BoxDecoration(
      gradient: LinearGradient(
        colors: gradientColors,
        stops: stops,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: Colors.black.withOpacity(1 - max(0, brightness - 0.2)),
        ),
        Container(
          decoration:
              _simpleBox([Colors.white.withOpacity(brightness), color.withOpacity(1 - max(0, brightness - 0.5))], [0.2 + ((1 - brightness) / 10), 1 - ((1 - brightness) / 10)]),
        ),
      ],
    );
  }
}
