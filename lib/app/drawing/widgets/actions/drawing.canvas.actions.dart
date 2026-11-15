import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/drawing/widgets/actions/clip.mode.button.dart';
import 'package:kids_drawing_flutter/app/drawing/widgets/actions/complete.check.button.dart';

/// Top complete check + bottom clip-mode toggle beside the canvas.
class DrawingCanvasActions extends StatelessWidget {
  final bool hasPaint;
  final bool clipToRegions;
  final VoidCallback onComplete;
  final VoidCallback onToggleClip;

  const DrawingCanvasActions({
    super.key,
    required this.hasPaint,
    required this.clipToRegions,
    required this.onComplete,
    required this.onToggleClip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CompleteCheckButton(visible: hasPaint, onPressed: onComplete),
          ClipModeButton(
            clipToRegions: clipToRegions,
            onPressed: onToggleClip,
          ),
        ],
      ),
    );
  }
}
