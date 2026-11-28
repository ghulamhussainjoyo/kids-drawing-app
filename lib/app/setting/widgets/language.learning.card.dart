import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';
import 'package:provider/provider.dart';

class LanguageLearningCard extends StatelessWidget {
  final String languageName;
  final double progress;
  final VoidCallback onDismiss;

  const LanguageLearningCard({
    super.key,
    required this.languageName,
    required this.progress,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final vm = context.read<SettingViewModel>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.rs(16)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(context.rs(24)),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F5FF),
                borderRadius: BorderRadius.circular(context.rs(20)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1A000000),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('📖  🐱', style: TextStyle(fontSize: context.rs(40))),
                  SizedBox(height: context.rs(16)),
                  Text(
                    vm.tf('language.narrator_learning', {
                      'language': languageName,
                    }),
                    textAlign: TextAlign.center,
                    style: AppTypography.boldStyle(
                      fontSize: context.rs(18),
                      color: const Color(0xFF2D2244),
                    ),
                  ),
                  SizedBox(height: context.rs(8)),
                  Text(
                    vm.t('language.learning_description'),
                    textAlign: TextAlign.center,
                    style: AppTypography.semiBoldStyle(
                      fontSize: context.rs(13),
                      color: const Color(0xFF8E819E),
                    ),
                  ),
                  SizedBox(height: context.rs(20)),
                  _ProgressBar(
                    progress: progress.clamp(0.0, 1.0),
                    height: context.rs(8),
                  ),
                  SizedBox(height: context.rs(20)),
                  SizedBox(
                    width: context.rs(120),
                    height: context.rs(40),
                    child: CupertinoButton(
                      padding: EdgeInsets.zero,
                      color: AppColors.purple,
                      borderRadius: BorderRadius.circular(context.rs(20)),
                      onPressed: onDismiss,
                      child: Text(
                        vm.t('language.got_it'),
                        style: AppTypography.boldStyle(
                          fontSize: context.rs(14),
                          color: const Color(0xFFFFFFFF),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final double progress;
  final double height;

  const _ProgressBar({required this.progress, required this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: SizedBox(
        height: height,
        child: Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: Color(0xFFE8E0F0))),
            FractionallySizedBox(
              widthFactor: progress,
              child: const ColoredBox(color: AppColors.purple),
            ),
          ],
        ),
      ),
    );
  }
}
