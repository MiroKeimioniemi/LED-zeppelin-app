import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Midground extends StatelessWidget {
  const Midground({required this.color});
  final Color color;
  final String svg1 = 
    '''<svg width="100%" height="374" viewBox="0 0 100% 380" fill="none" xmlns="http://www.w3.org/2000/svg">
       <path d="M82 43.0833C60.4 36.4833 18.3333 69.6667 0 87.0833V374H360V0C335.667 18.9444 271.4 58.85 209 66.9167C131 77 109 51.3333 82 43.0833Z" fill="#BFBFBF"/>
       </svg>''';
  final String svg2 = 
    '''<svg width="100%" height="282" viewBox="0 0 360 280" fill="none" xmlns="http://www.w3.org/2000/svg">
       <path d="M170 36.0187C87 73.3659 39.3333 43.9252 -1 31.6262V282H360V0C307.333 10.5421 267 -7.62799 170 36.0187Z" fill="#8B8B8B"/>
       </svg>''';
  final String svg3 = 
    '''<svg width="100%" height="233" viewBox="0 0 360 240" fill="none" xmlns="http://www.w3.org/2000/svg">
       <path d="M144 49.6958C79.2 26.2329 21 85.5419 0 118.129V233H360V0C315 26.3415 208.8 73.1587 144 49.6958Z" fill="#545454"/>
       </svg>''';

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: <Widget>[
        ColorFiltered(
          colorFilter: ColorFilter.mode(HSLColor.fromColor(color).withLightness(0.9).toColor(), BlendMode.srcIn),
          child: SvgPicture.string(svg1),
        ),
        ColorFiltered(
          colorFilter: ColorFilter.mode(HSLColor.fromColor(color).withLightness(0.8).toColor(), BlendMode.srcIn),
          child: SvgPicture.string(svg2),
        ),
        ColorFiltered(
          colorFilter: ColorFilter.mode(HSLColor.fromColor(color).withLightness(0.7).toColor(), BlendMode.srcIn),
          child: SvgPicture.string(svg3),
        ),
      ],
    );
  }
}