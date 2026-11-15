import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';

class SubscriptionPanel extends StatelessWidget {
  const SubscriptionPanel({super.key});

  void openPaywallPlaceholder(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (context) => const CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(
            middle: Text('Try Free'),
          ),
          child: Center(
            child: Text('Paywall coming soon'),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 8, bottom: 20, left: 16, right: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Subscription',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF221A30),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => openPaywallPlaceholder(context),
            child: SizedBox(
              height: 110,
              width: double.infinity,
              child: CustomPaint(
                painter: _TicketPainter(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 7,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D1B00),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'No plan yet',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFFD464),
                                ),
                              ),
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Try Free for 7 days',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    CupertinoIcons.chevron_forward,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        flex: 2,
                        child: Center(
                          child: Icon(
                            Icons.star_rounded,
                            size: 44,
                            color: Color(0xFF3A240C),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xCCFFFFFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5DEEE)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.purple,
                    ),
                    child: const Icon(
                      CupertinoIcons.arrow_2_circlepath,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Restore Purchases',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF261D32),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Privacy Policy',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.purple,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text(
                    '•',
                    style: TextStyle(color: Color(0xFF9F98AA), fontSize: 14),
                  ),
                ),
                Text(
                  'Terms of Use',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.purple,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    const radius = 16.0;
    const notchR = 10.0;
    final midX = size.width * 0.72;

    path.moveTo(radius, 0);
    path.lineTo(midX - notchR, 0);
    path.arcToPoint(
      Offset(midX + notchR, 0),
      radius: const Radius.circular(notchR),
      clockwise: false,
    );
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(
      size.width,
      size.height,
      size.width - radius,
      size.height,
    );
    path.lineTo(midX + notchR, size.height);
    path.arcToPoint(
      Offset(midX - notchR, size.height),
      radius: const Radius.circular(notchR),
      clockwise: false,
    );
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.close();

    final fill = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFFFFDF7D), Color(0xFFEDB02B)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Offset.zero & size);
    canvas.drawPath(path, fill);

    final dashPaint = Paint()
      ..color = const Color(0x669B670B)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    const dash = 4.0;
    const gap = 3.0;
    var y = 16.0;
    while (y < size.height - 16) {
      canvas.drawLine(Offset(midX, y), Offset(midX, y + dash), dashPaint);
      y += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant _TicketPainter oldDelegate) => false;
}
