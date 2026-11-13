import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/types/genre/genre.model.dart';

/// Title letters sit just outside the genre circle.
class GenreTitle extends StatelessWidget {
  final GenreModel genre;
  final double circleSize;

  const GenreTitle({super.key, required this.genre, required this.circleSize});

  double get center => circleSize / 2;
  double get fontSize => circleSize * 0.13;
  double get gap => circleSize * (12 / 300);

  /// Letter centers. Half a glyph plus [gap] stays clear of the rim.
  double get letterRadius => center + gap + fontSize * 0.55;

  /// Space the arch needs above the circle box.
  double get topOverhang => gap + fontSize;

  /// 0 pulls every letter inside the oval. 1 rests them on [letterRadius].
  double hideScale(double closeness) {
    final hiddenScale = (center - fontSize) / letterRadius;
    return hiddenScale + (1 - hiddenScale) * closeness;
  }

  @override
  Widget build(BuildContext context) {
    final name = genre.name.toUpperCase();
    if (name.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: circleSize,
      height: circleSize,
      child: Stack(clipBehavior: Clip.none, children: buildLetterWidgets(name)),
    );
  }

  List<Widget> buildLetterWidgets(String name) {
    final widths = letterWidths(name);
    final totalWidth = widths.fold(0.0, (sum, width) => sum + width);
    final letters = <Widget>[];
    var walked = 0.0;

    for (var index = 0; index < name.length; index++) {
      final letterWidth = widths[index];
      final mid = walked + letterWidth / 2;
      final theta = (mid - totalWidth / 2) / letterRadius;
      final position = letterPosition(theta);

      letters.add(
        Positioned(
          left: position.dx - letterWidth / 2,
          top: position.dy - fontSize / 2,
          child: Transform.rotate(
            angle: theta,
            child: _GenreLetter(
              char: name[index],
              fontSize: fontSize,
              fillColors: genre.titleFillColors,
              outlineColor: genre.titleOutlineColor,
            ),
          ),
        ),
      );

      walked += letterWidth;
    }

    return letters;
  }

  /// Real glyph width so I and W take the space they need.
  List<double> letterWidths(String name) {
    final style = TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      height: 1,
    );
    final widths = <double>[];
    for (var index = 0; index < name.length; index++) {
      final painter = TextPainter(
        text: TextSpan(text: name[index], style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      widths.add(painter.width);
    }
    return widths;
  }

  /// Theta 0 is the top of the circle. Ends follow the rim, with [gap] outside it.
  Offset letterPosition(double theta) {
    final x = center + letterRadius * math.sin(theta);
    final y = center - letterRadius * math.cos(theta);
    return Offset(x, y);
  }
}

/// One character: shadow, then outline, then fill.
class _GenreLetter extends StatelessWidget {
  final String char;
  final double fontSize;
  final List<Color> fillColors;
  final Color outlineColor;

  const _GenreLetter({
    required this.char,
    required this.fontSize,
    required this.fillColors,
    required this.outlineColor,
  });

  TextStyle heavyStyle({Color? color, Paint? foreground}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.w900,
      height: 1,
      color: color,
      foreground: foreground,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [buildShadow(), buildOutline(), buildFill()],
    );
  }

  Widget buildShadow() {
    return Transform.translate(
      offset: const Offset(1.5, 2),
      child: Text(char, style: heavyStyle(color: const Color(0x66000000))),
    );
  }

  Widget buildOutline() {
    final outlinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = fontSize * 0.18
      ..strokeJoin = StrokeJoin.round
      ..color = outlineColor;

    return Text(char, style: heavyStyle(foreground: outlinePaint));
  }

  Widget buildFill() {
    if (fillColors.length <= 1) {
      final color = fillColors.isEmpty
          ? const Color(0xFFFFFFFF)
          : fillColors.first;
      return Text(char, style: heavyStyle(color: color));
    }

    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) {
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: fillColors,
        ).createShader(bounds);
      },
      child: Text(char, style: heavyStyle(color: const Color(0xFFFFFFFF))),
    );
  }
}
