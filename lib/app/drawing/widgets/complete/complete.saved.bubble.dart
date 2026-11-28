import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/state/setting/setting.view-model.dart';
import 'package:provider/provider.dart';

/// Brief "Saved!" feedback after a successful gallery download.
class CompleteSavedBubble extends StatelessWidget {
  const CompleteSavedBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Builder(
        builder: (context) {
          final vm = context.read<SettingViewModel>();
          return Text(
            vm.t('drawing.saved'),
            style: AppTypography.boldStyle(
              color: const Color(0xFF3A3A3A),
              fontSize: 18,
            ),
          );
        },
      ),
    );
  }
}
