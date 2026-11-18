import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';

class InterestTile extends StatefulWidget {
  final String id;
  final String label;
  final String? svgPath;
  final String? imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  const InterestTile({
    super.key,
    required this.id,
    required this.label,
    this.svgPath,
    this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<InterestTile> createState() => _InterestTileState();
}

class _InterestTileState extends State<InterestTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    if (widget.isSelected) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant InterestTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.isSelected && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildGraphic(double size) {
    // Prefer gallery/image until SVG assets land under assets/svgs/interests/.
    Widget graphic;
    if (widget.imagePath != null) {
      graphic = Image.asset(
        widget.imagePath!,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (_, _, _) {
          if (widget.svgPath == null) {
            return Icon(
              CupertinoIcons.paintbrush_fill,
              color: AppColors.purple,
              size: size * 0.4,
            );
          }
          return SvgPicture.asset(
            widget.svgPath!,
            width: size * 0.7,
            height: size * 0.7,
            fit: BoxFit.contain,
          );
        },
      );
    } else if (widget.svgPath != null) {
      graphic = SvgPicture.asset(
        widget.svgPath!,
        width: size * 0.7,
        height: size * 0.7,
        fit: BoxFit.contain,
      );
    } else {
      graphic = Icon(
        CupertinoIcons.paintbrush_fill,
        color: AppColors.purple,
        size: size * 0.4,
      );
    }

    if (!widget.isSelected) {
      return ColorFiltered(
        colorFilter: const ColorFilter.matrix(<double>[
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 1, 0,
        ]),
        child: graphic,
      );
    }
    return graphic;
  }

  @override
  Widget build(BuildContext context) {
    final size = context.rs(72);

    return Padding(
      padding: EdgeInsets.only(right: context.rs(12)),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final bounce = widget.isSelected
                    ? 1.0 + (_controller.value * 0.06)
                    : 1.0;
                return Transform.scale(scale: bounce, child: child);
              },
              child: Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(context.rs(16)),
                  color: const Color(0xFFFFFFFF),
                  border: Border.all(
                    color: widget.isSelected
                        ? AppColors.purple
                        : const Color(0xFFDED8E7),
                    width: widget.isSelected ? 3 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(context.rs(13)),
                  child: Center(child: _buildGraphic(size)),
                ),
              ),
            ),
            SizedBox(height: context.rs(6)),
            Text(
              widget.label,
              style: widget.isSelected
                  ? AppTypography.boldStyle(
                      fontSize: context.rs(12),
                      color: AppColors.purple,
                    )
                  : AppTypography.semiBoldStyle(
                      fontSize: context.rs(12),
                      color: const Color(0xFF5E5669),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
