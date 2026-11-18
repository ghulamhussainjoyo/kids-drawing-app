import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';

/// Custom volume control: purple track + white pill thumb.
class MusicVolumeSlider extends StatelessWidget {
  final double value;
  final bool enabled;
  final ValueChanged<double> onChanged;

  const MusicVolumeSlider({
    super.key,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final trackHeight = context.rs(10);
    final thumbWidth = context.rs(28);
    final thumbHeight = context.rs(20);

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final clamped = value.clamp(0.0, 1.0);
          final thumbLeft = (width - thumbWidth) * clamped;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: enabled
                ? (details) {
                    final local = details.localPosition.dx;
                    final next = (local / width).clamp(0.0, 1.0);
                    onChanged(next);
                  }
                : null,
            onTapDown: enabled
                ? (details) {
                    final next = (details.localPosition.dx / width).clamp(
                      0.0,
                      1.0,
                    );
                    onChanged(next);
                  }
                : null,
            child: SizedBox(
              height: context.rs(36),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  Container(
                    height: trackHeight,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8E0F0),
                      borderRadius: BorderRadius.circular(trackHeight),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: clamped,
                    child: Container(
                      height: trackHeight,
                      decoration: BoxDecoration(
                        color: AppColors.purple,
                        borderRadius: BorderRadius.circular(trackHeight),
                      ),
                    ),
                  ),
                  Positioned(
                    left: thumbLeft,
                    child: Container(
                      width: thumbWidth,
                      height: thumbHeight,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFFFF),
                        borderRadius: BorderRadius.circular(thumbHeight),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
