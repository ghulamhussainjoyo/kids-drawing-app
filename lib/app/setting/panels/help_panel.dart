import 'package:flutter/cupertino.dart';

class HelpPanel extends StatelessWidget {
  const HelpPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(top: 8, bottom: 20, left: 16, right: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Help',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF221A30),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Contact us / FAQ links (coming soon)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF5D5466),
            ),
          ),
        ],
      ),
    );
  }
}
