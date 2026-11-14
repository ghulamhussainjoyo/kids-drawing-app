import 'dart:ui';

/// Parses SVG-ish path commands used in artwork JSON: M L C Q H V Z.
class ArtworkPathParser {
  Path parse(String data) {
    final path = Path();
    final tokens = _tokenize(data);
    var index = 0;
    var current = Offset.zero;
    var start = Offset.zero;
    String? command;

    while (index < tokens.length) {
      final token = tokens[index];
      if (_isCommand(token)) {
        command = token;
        index++;
      }
      if (command == null) {
        break;
      }

      switch (command) {
        case 'M':
          final x = _number(tokens, index++);
          final y = _number(tokens, index++);
          current = Offset(x, y);
          start = current;
          path.moveTo(x, y);
          command = 'L';
        case 'L':
          final x = _number(tokens, index++);
          final y = _number(tokens, index++);
          current = Offset(x, y);
          path.lineTo(x, y);
        case 'H':
          final x = _number(tokens, index++);
          current = Offset(x, current.dy);
          path.lineTo(current.dx, current.dy);
        case 'V':
          final y = _number(tokens, index++);
          current = Offset(current.dx, y);
          path.lineTo(current.dx, current.dy);
        case 'C':
          final x1 = _number(tokens, index++);
          final y1 = _number(tokens, index++);
          final x2 = _number(tokens, index++);
          final y2 = _number(tokens, index++);
          final x = _number(tokens, index++);
          final y = _number(tokens, index++);
          current = Offset(x, y);
          path.cubicTo(x1, y1, x2, y2, x, y);
        case 'Q':
          final x1 = _number(tokens, index++);
          final y1 = _number(tokens, index++);
          final x = _number(tokens, index++);
          final y = _number(tokens, index++);
          current = Offset(x, y);
          path.quadraticBezierTo(x1, y1, x, y);
        case 'Z':
        case 'z':
          path.close();
          current = start;
          command = null;
        default:
          throw FormatException('Unsupported path command: $command');
      }
    }

    return path;
  }

  List<String> _tokenize(String data) {
    final cleaned = data
        .replaceAll(',', ' ')
        .replaceAllMapped(RegExp(r'([MmLlHhVvCcQqZz])'), (match) => ' ${match[1]} ')
        .replaceAllMapped(RegExp(r'-'), (match) => ' -');
    return cleaned
        .split(RegExp(r'\s+'))
        .where((token) => token.isNotEmpty)
        .toList();
  }

  bool _isCommand(String token) {
    return RegExp(r'^[MmLlHhVvCcQqZz]$').hasMatch(token);
  }

  double _number(List<String> tokens, int index) {
    if (index >= tokens.length) {
      throw const FormatException('Path data ended early');
    }
    return double.parse(tokens[index]);
  }
}
