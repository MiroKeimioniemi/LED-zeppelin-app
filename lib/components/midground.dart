import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Midground widget consists of three stacked, predefined SVG images, the colors 
// of which are progressively darker shades of the color provided as a parameter
class Midground extends StatelessWidget {

  final Color color;
  final double brightness;
  final bool isOn;
  
  // Midground widget constructor with color, brightness and isOn parameters
  const Midground({super.key, required this.color, required this.brightness, required this.isOn});

  // SVG definitions
  // ViewBox represents the coordinate system of the SVG image, not necessarily the actual size of the image, which is defined using the SvgPicture parameters.
  final String svg1 = 
    '''<svg viewBox="0 0 360 374" fill="none" xmlns="http://www.w3.org/2000/svg">
       <path d="M82 43.0833C60.4 36.4833 18.3333 69.6667 0 87.0833V374H360V0C335.667 18.9444 271.4 58.85 209 66.9167C131 77 109 51.3333 82 43.0833Z" fill="#BFBFBF"/>
       </svg>''';
  final String svg2 = 
    '''<svg viewBox="0 0 360 282" fill="none" xmlns="http://www.w3.org/2000/svg">
       <path d="M170 36.0187C87 73.3659 39.3333 43.9252 0 31.6262V282H360V0C307.333 10.5421 267 -7.62799 170 36.0187Z" fill="#8B8B8B"/>
       </svg>''';
  final String svg3 = 
    '''<svg viewBox="0 0 360 233" fill="none" xmlns="http://www.w3.org/2000/svg">
       <path d="M144 49.6958C79.2 26.2329 21 85.5419 0 118.129V233H360V0C315 26.3415 208.8 73.1587 144 49.6958Z" fill="#545454"/>
       </svg>''';

  // Build method for the Midground widget
  @override
  Widget build(BuildContext context) {
    // Return a stack of the three SVG images with color filters applied.

    // The progressively darker shades are obtained by applying a color filter with the lightness of the color
    // adjusted as an HSL (Hue, Saturation, Lightness) value and then converting it back to the RGB color.

    // The SVG images are rendered from the string definitions with a width equal to the screen width.
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        ColorFiltered(
          colorFilter: ColorFilter.mode(isOn? HSLColor.fromColor(color).withLightness(max(0.1, brightness / 2)).toColor() : Color.fromARGB(255, 30, 30, 30), BlendMode.srcIn),
          child: SvgPicture.string(svg1, height: MediaQuery.of(context).size.height / 2, fit: BoxFit.fill,),
        ),
        ColorFiltered(
          colorFilter: ColorFilter.mode(isOn? HSLColor.fromColor(color).withLightness(max(0.07, brightness / 2 - 0.1)).toColor() : Color.fromARGB(255, 20, 20, 20), BlendMode.srcIn),
          child: SvgPicture.string(svg2, height: MediaQuery.of(context).size.height / 2.7, fit: BoxFit.fill,),
        ),
        ColorFiltered(
          colorFilter: ColorFilter.mode(isOn? HSLColor.fromColor(color).withLightness(max(0.03, brightness / 2 - 0.2)).toColor() : const Color.fromARGB(255, 10, 10, 10), BlendMode.srcIn),
          child: SvgPicture.string(svg3, height: MediaQuery.of(context).size.height / 3.2, fit: BoxFit.fill,),
        ),
      ],
    );
  }
}