import 'dart:ui';
import 'package:flutter/material.dart';

// CelestialBody widget consists of a circular container with a gradient overlay
class CelestialBody extends StatelessWidget {

  final bool isDay;
  final double brightness;
  final Color color;

  // CelestialBody widget constructor with isDay, brightness and color parameters
  const CelestialBody({super.key, required this.isDay, required this.brightness, required this.color});

  @override
  Widget build(BuildContext context) {
    // Return an animated container with a gradient overlay that changes based on the brightness value to simulate a sunrise/sunset effect by adjusting the alignment of the container.
    return AnimatedContainer(
      duration: const Duration(seconds: 0),
      curve: Curves.easeInOut,
      // Change vertical alignment based on the brightness value by linearly interpolating between 0.35 and -0.35
      alignment: Alignment(0, lerpDouble(0.35, -0.35, brightness)!),
      // Sun
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [HSLColor.fromColor(color).withLightness(0.8).toColor(), color],
          ),
          boxShadow: [
            BoxShadow(
              color: HSLColor.fromColor(color).withLightness(0.2).toColor().withOpacity(0.1),
              blurRadius: 100,
              spreadRadius: 100,
            ),
          ],
        ),
      ),
    );
  }
}