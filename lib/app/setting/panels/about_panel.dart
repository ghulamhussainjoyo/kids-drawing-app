import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.card.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.colors.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.panel.scaffold.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPanel extends StatelessWidget {
  const AboutPanel({super.key});

  static final Future<PackageInfo> _info = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return SettingPanelScaffold(
      title: 'About',
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SettingCard(
            radius: 20,
            padding: EdgeInsets.all(context.rs(16)),
            margin: EdgeInsets.only(bottom: context.rs(14)),
            child: Row(
              children: [
                Container(
                  width: context.rs(50),
                  height: context.rs(50),
                  decoration: BoxDecoration(
                    color: AppColors.lavender,
                    borderRadius: BorderRadius.circular(context.rs(14)),
                  ),
                  child: Icon(
                    CupertinoIcons.paintbrush_fill,
                    color: AppColors.purple,
                    size: context.rs(26),
                  ),
                ),
                SizedBox(width: context.rs(14)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kids Drawing',
                        style: AppTypography.boldStyle(
                          fontSize: context.rs(16),
                          color: SettingColors.title,
                        ),
                      ),
                      SizedBox(height: context.rs(2)),
                      FutureBuilder<PackageInfo>(
                        future: _info,
                        builder: (context, snap) {
                          final info = snap.data;
                          return Text(
                            info == null
                                ? 'Version …'
                                : 'Version ${info.version} (Build ${info.buildNumber})',
                            style: AppTypography.numericStyle(
                              fontSize: context.rs(12),
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF7C7286),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(context.rs(14)),
            decoration: BoxDecoration(
              color: const Color(0x8CFFFFFF),
              borderRadius: BorderRadius.circular(context.rs(16)),
            ),
            child: Text(
              'Designed with love for young creative minds. Unleash imagination with puppies, colors, and art!',
              style: AppTypography.semiBoldStyle(
                fontSize: context.rs(13),
                color: const Color(0xFF5D5466),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
