import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';

class AboutPanel extends StatelessWidget {
  const AboutPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 20, left: 16, right: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF221A30),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE5DEEE)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppColors.lavender,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    CupertinoIcons.paintbrush_fill,
                    color: AppColors.purple,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kids Drawing',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF221A30),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Version 1.0.0 (Build 1)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7C7286),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Designed with ❤️ for young creative minds. Unleash imagination with puppies, colors, and art!',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF5D5466),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
