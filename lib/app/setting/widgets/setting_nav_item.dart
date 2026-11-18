import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';

class SettingNavItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SettingNavItem({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.rs(3)),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: EdgeInsets.symmetric(
            horizontal: context.rs(14),
            vertical: context.rs(8),
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xE6FFFFFF)
                : const Color(0x00000000),
            borderRadius: BorderRadius.circular(context.rs(10)),
          ),
          child: Row(
            children: [
              SizedBox(
                width: context.rs(24),
                height: context.rs(24),
                child: Center(child: icon),
              ),
              SizedBox(width: context.rs(12)),
              Expanded(
                child: Text(
                  label,
                  style: isSelected
                      ? AppTypography.boldStyle(
                          fontSize: context.rs(15),
                          color: AppColors.purple,
                        )
                      : AppTypography.semiBoldStyle(
                          fontSize: context.rs(15),
                          color: const Color(0xFF3A3344),
                        ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
