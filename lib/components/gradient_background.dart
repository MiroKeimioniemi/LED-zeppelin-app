import 'dart:math';
import 'package:flutter/material.dart';

// GradientBackground widget consists of a solid color background with a gradient overlay,
// the colors of which change dynamically based on the brightness and isOn parameters.
class GradientBackground extends StatelessWidget {

  final Color color;
  final double brightness;
  final bool isOn;

  // GradientBackground widget constructor with color, brightness and isOn parameters.
  const GradientBackground(
      {super.key,
      required this.color,
      required this.brightness,
      required this.isOn});

  // A function to return a BoxDecoration with a gradient overlay of the specified colors and stops.
  BoxDecoration _simpleBox(List<Color> colors, List<double> stops) {

    // If the lamp is on, the gradient colors are the provided colors, otherwise they are shades of black.
    // The number of gradient stops must match the number of gradient colors.
    List<Color> gradientColors;
    List<double> gradientStops;
    if (isOn) {
      gradientColors = colors;
      gradientStops = stops;
    } else {
      gradientColors = [const Color.fromARGB(255, 55, 55, 55), Colors.black];
      gradientStops = [0.0, 0.75];
    }

    return BoxDecoration(
      gradient: LinearGradient(
        colors: gradientColors,
        stops: gradientStops,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
    );
  }

  // Build method for the GradientBackground widget
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Solid black background color to provide more contrast for low brightness values.
        Container(
          color: Colors.black.withOpacity(1 - max(0, brightness - 0.2)),
        ),
        // Gradient overlay with the specified colors and stops.
        // The brightness value reduces the opacity of the gradient overlay to simulate light intensity when the color changes to the white of the background.
        // The stops open up the gradient to the top and bottom of the screen as brighteness increases to simulate a sunrise effect.
        Container(
          decoration:
              _simpleBox([Colors.white.withOpacity(brightness), color.withOpacity(1 - max(0, brightness - 0.5))], [0.1 + ((1 - brightness) / 10), 1 - ((1 - brightness) / 10)]),
        ),
      ],
    );
  }
}
