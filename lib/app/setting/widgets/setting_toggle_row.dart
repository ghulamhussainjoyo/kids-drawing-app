import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';

class SettingToggleRow extends StatelessWidget {
  final Widget icon;
  final String title;
  final String description;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingToggleRow({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  void _showInfoDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: Text(title),
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(description),
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('OK'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: Center(child: icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Row(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2C2438),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => _showInfoDialog(context),
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFB5ACB9), width: 1.2),
                    ),
                    child: const Center(
                      child: Text(
                        'i',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF887D8E),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: CupertinoSwitch(
              value: value,
              activeTrackColor: AppColors.purple,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}
