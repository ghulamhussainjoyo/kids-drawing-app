import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.colors.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';

/// Rounded white option card used across settings panels.
class SettingCard extends StatelessWidget {
  final Widget child;
  final bool selected;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double radius;

  const SettingCard({
    super.key,
    required this.child,
    this.selected = false,
    this.padding,
    this.margin,
    this.radius = 16,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      margin: margin ?? EdgeInsets.only(bottom: context.rs(10)),
      padding:
          padding ??
          EdgeInsets.symmetric(
            horizontal: context.rs(14),
            vertical: context.rs(12),
          ),
      decoration: BoxDecoration(
        color: selected
            ? SettingColors.cardFillSelected
            : SettingColors.cardFill,
        borderRadius: BorderRadius.circular(context.rs(radius)),
        border: Border.all(
          color: selected ? AppColors.purple : SettingColors.cardBorder,
          width: selected ? 2 : 1,
        ),
      ),
      child: child,
    );
  }
}
