import 'package:flutter/material.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/widgets/circle.button.dart';
import 'package:kids_drawing_flutter/features/drawing/widgets/tools/size.slider.display.dart';

class ControllerTools extends StatefulWidget {
  final double density;
  final VoidCallback? onBack;
  final VoidCallback? onUndo;
  final VoidCallback? onRedo;
  final VoidCallback? onEraser;
  final String selectedCategoryImage;
  final ValueChanged<double> onDensityChanged;

  const ControllerTools({
    super.key,
    this.onBack,
    this.onUndo,
    this.onRedo,
    this.onEraser,
    required this.density,
    required this.selectedCategoryImage,
    required this.onDensityChanged,
  });

  @override
  State<ControllerTools> createState() => _ControllerToolsState();
}

class _ControllerToolsState extends State<ControllerTools> {
  late double density;

  @override
  void initState() {
    super.initState();
    density = widget.density;
  }

  void onDensityDrag(double value) {
    setState(() {
      density = value;
    });
    widget.onDensityChanged(value);
  }

  Color getUndoColor(VoidCallback? onUndo) {
    if (onUndo == null) {
      return AppColors.disabled;
    }
    return AppColors.purple;
  }

  Color getRedoColor(VoidCallback? onRedo) {
    if (onRedo == null) {
      return AppColors.disabled;
    }
    return AppColors.purple;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonSize = (constraints.maxWidth * 0.38).clamp(36.0, 48.0);
        final badgeSize = (constraints.maxWidth * 0.38).clamp(40.0, 56.0);
        final undoColor = getUndoColor(widget.onUndo);
        final redoColor = getRedoColor(widget.onRedo);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Column(
            children: [
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: Center(
                      child: CircleButton(
                        size: buttonSize,
                        color: AppColors.purple,
                        onPressed: widget.onBack,
                        image: const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: CircleButton(
                        size: buttonSize,
                        color: AppColors.purple,
                        onPressed: widget.onEraser,
                        image: const Icon(
                          Icons.cleaning_services,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    ClipOval(
                      child: SizedBox(
                        width: badgeSize,
                        height: badgeSize,
                        child: ColoredBox(
                          color: AppColors.lavender,
                          child: Image.asset(
                            widget.selectedCategoryImage,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, sliderConstraints) {
                          final sliderWidth = (constraints.maxWidth * 0.42)
                              .clamp(40.0, 64.0);
                          return Center(
                            child: SizeSliderDisplay(
                              width: sliderWidth,
                              height: sliderConstraints.maxHeight,
                              value: density,
                              onChanged: onDensityDrag,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                spacing: 12,
                children: [
                  Expanded(
                    child: Center(
                      child: CircleButton(
                        size: buttonSize,
                        color: undoColor,
                        onPressed: widget.onUndo,
                        image: const Icon(
                          Icons.undo_rounded,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: CircleButton(
                        size: buttonSize,
                        color: redoColor,
                        onPressed: widget.onRedo,
                        image: const Icon(
                          Icons.redo_rounded,
                          color: Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
