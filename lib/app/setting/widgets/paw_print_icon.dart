import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class PawPrintIcon extends StatelessWidget {
  final double size;
  final Color color;

  const PawPrintIcon({
    super.key,
    this.size = 24.0,
    this.color = const Color(0xFF7B35E0),
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/svgs/paw_print.svg',
      width: size,
      height: size,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }
}
