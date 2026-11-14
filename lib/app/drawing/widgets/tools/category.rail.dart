import 'package:flutter/material.dart';
import 'package:kids_drawing_flutter/types/category.model.dart';
import 'package:kids_drawing_flutter/core/ui/widgets/rounded.button.dart';

class CategoryRail extends StatelessWidget {
  final double gap;
  final double buttonSize;
  final double imageSize;
  final double verticalPadding;
  final double horizontalPadding;
  final String selectedCategory;
  final List<CategoryModel> categories;
  final ValueChanged<String> onCategoryTap;

  const CategoryRail({
    super.key,
    required this.gap,
    required this.buttonSize,
    required this.imageSize,
    required this.categories,
    required this.verticalPadding,
    required this.onCategoryTap,
    required this.horizontalPadding,
    required this.selectedCategory,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      primary: false,
      clipBehavior: Clip.none,
      itemCount: categories.length,
      padding: EdgeInsets.symmetric(
        vertical: verticalPadding,
        horizontal: horizontalPadding,
      ),
      separatorBuilder: (context, index) => SizedBox(height: gap),
      itemBuilder: (context, index) {
        final category = categories[index];
        final selected = category.name == selectedCategory;
        final fill = selected ? category.activeColor : category.mutedColor;

        return Align(
          alignment: Alignment.centerRight,
          child: Transform.scale(
            scale: selected ? 1.08 : 1.0,
            child: RoundedButton(
              size: buttonSize,
              imageSize: imageSize,
              backgroundColor: fill,
              onPressed: () => onCategoryTap(category.name),
              image: Image.asset(category.image),
            ),
          ),
        );
      },
    );
  }
}
