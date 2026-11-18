import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/model/setting.section.x.dart';
import 'package:kids_drawing_flutter/app/setting/model/setting_section.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting_nav_item.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';

/// Left glass nav column for the settings dialog.
class SettingNav extends StatelessWidget {
  final SettingSection active;
  final ValueChanged<SettingSection> onSelect;

  const SettingNav({super.key, required this.active, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(context.rs(16));

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: context.rs(10),
          vertical: context.rs(8),
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0x73FFFFFF),
                borderRadius: radius,
                border: Border.all(color: const Color(0xCCFFFFFF)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  context.rs(10),
                  context.rs(14),
                  context.rs(8),
                  context.rs(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        left: context.rs(8),
                        bottom: context.rs(8),
                      ),
                      child: Text(
                        'Settings',
                        style: AppTypography.boldStyle(
                          fontSize: context.rs(21),
                          color: const Color(0xFF221A30),
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            for (final section in SettingSection.values)
                              SettingNavItem(
                                icon: Icon(
                                  section.icon,
                                  color: section.color,
                                  size: context.rs(19),
                                ),
                                label: section.label,
                                isSelected: active == section,
                                onTap: () => onSelect(section),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
