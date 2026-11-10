import 'package:flutter/cupertino.dart';

class GalleryBoxItem extends StatelessWidget {
  const GalleryBoxItem({
    super.key,
    required this.title,
    required this.onPressed,
  });

  final String title;
  final Function(BuildContext, String) onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onPressed(context, title),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: CupertinoColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CupertinoColors.black, width: 3),
        ),
        child: Center(child: Text(title)),
      ),
    );
  }
}
