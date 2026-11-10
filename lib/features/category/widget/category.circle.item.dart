import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';

class CategoryCircleItem extends StatelessWidget {
  final String name;
  final double scale;
  final bool focused;
  final double closeness;
  final void Function(String name) onPressed;

  const CategoryCircleItem({
    super.key,
    required this.name,
    required this.scale,
    required this.focused,
    required this.closeness,
    required this.onPressed,
  });

  double getItemSize(BuildContext context, double size) {
    return MediaQuery.of(context).size.width * size;
  }

  @override
  Widget build(BuildContext context) {
    final circleSize = getItemSize(context, 0.25);
    final rise = circleSize / 2.5 + getItemSize(context, 0.04);
    return Center(
      child: GestureDetector(
        onTap: () => onPressed(name),
        behavior: HitTestBehavior.opaque,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Transform.translate(
              offset: Offset(0, -rise * closeness),
              child: Opacity(opacity: closeness, child: Text(name)),
            ),
            Transform.scale(
              scale: scale,
              child: Container(
                width: circleSize,
                height: circleSize,
                decoration: const BoxDecoration(
                  color: AppColors.purple,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
