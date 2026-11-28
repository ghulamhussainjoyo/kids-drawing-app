import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.card.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.colors.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.panel.scaffold.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

class AboutPanel extends StatelessWidget {
  const AboutPanel({super.key});

  static final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  static String _versionLine(SettingViewModel settings, PackageInfo? info) {
    if (info == null) return settings.t('about.version_loading');
    return settings.tf('about.version_format', {
      'version': info.version,
      'build': info.buildNumber,
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingViewModel>();

    return SettingPanelScaffold(
      title: settings.t('about.title'),
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
                        settings.t('about.app_name'),
                        style: AppTypography.boldStyle(
                          fontSize: context.rs(16),
                          color: SettingColors.title,
                        ),
                      ),
                      SizedBox(height: context.rs(2)),
                      FutureBuilder<PackageInfo>(
                        future: _packageInfo,
                        builder: (context, snap) {
                          return Text(
                            _versionLine(settings, snap.data),
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
              settings.t('about.description'),
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
