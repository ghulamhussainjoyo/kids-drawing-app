import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';

/// Polaroid hung on the clothesline with clothespin accents and a date.
class CompletePolaroidCard extends StatelessWidget {
  final bool loading;
  final Uint8List? pngBytes;
  final String dateLabel;
  final bool showArtwork;
  final double? maxSide;

  const CompletePolaroidCard({
    super.key,
    required this.loading,
    required this.pngBytes,
    required this.dateLabel,
    this.showArtwork = true,
    this.maxSide,
  });

  Widget artworkChild() {
    if (!showArtwork || pngBytes == null) {
      return const ColoredBox(color: Color(0xFFF5F5F5));
    }
    if (loading) {
      return const Center(child: CupertinoActivityIndicator());
    }
    return Image.memory(pngBytes!, fit: BoxFit.cover);
  }

  @override
  Widget build(BuildContext context) {
    final fromShortest = MediaQuery.sizeOf(context).shortestSide * 0.36;
    double side = fromShortest;
    if (maxSide != null && maxSide! < side) {
      side = maxSide!;
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: side + 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [_ClothesPin(), _ClothesPin()],
          ),
        ),
        Transform.translate(
          offset: const Offset(0, -6),
          child: Container(
            width: side + 28,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 28),
            decoration: BoxDecoration(
              color: CupertinoColors.white,
              borderRadius: BorderRadius.circular(4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66000000),
                  blurRadius: 16,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(width: side, height: side, child: artworkChild()),
                const SizedBox(height: 12),
                Text(
                  dateLabel,
                  style: AppTypography.boldStyle(
                    color: const Color(0xFF3A3A3A),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ClothesPin extends StatelessWidget {
  const _ClothesPin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 28,
      decoration: BoxDecoration(
        color: const Color(0xFFC4A484),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: const Color(0xFF8B5A2B), width: 1),
      ),
    );
  }
}
