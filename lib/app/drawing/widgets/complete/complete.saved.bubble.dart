import 'package:flutter/cupertino.dart';

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
      child: const Text(
        'Saved!',
        style: TextStyle(
          color: Color(0xFF3A3A3A),
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
