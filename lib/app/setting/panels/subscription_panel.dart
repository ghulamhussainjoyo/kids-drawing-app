import 'package:flutter/cupertino.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.card.dart';
import 'package:kids_drawing_flutter/app/setting/widgets/setting.panel.scaffold.dart';
import 'package:kids_drawing_flutter/core/ui/button/press.button.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.colors.dart';
import 'package:kids_drawing_flutter/core/ui/theme/app.typography.dart';
import 'package:kids_drawing_flutter/utils/responsive.dart';

class SubscriptionPanel extends StatelessWidget {
  const SubscriptionPanel({super.key});

  void _openPaywall(BuildContext context) {
    Navigator.of(context).push(
      CupertinoPageRoute<void>(
        builder: (_) => const CupertinoPageScaffold(
          navigationBar: CupertinoNavigationBar(middle: Text('Try Free')),
          child: Center(child: Text('Paywall coming soon')),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SettingPanelScaffold(
      title: 'Subscription',
      onClose: () => Navigator.of(context).pop(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PlanTicket(onTap: () => _openPaywall(context)),
          SizedBox(height: context.rs(4)),
          PressButton(
            onPressed: () {},
            child: SettingCard(
              child: Row(
                children: [
                  Container(
                    width: context.rs(32),
                    height: context.rs(32),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.purple,
                    ),
                    child: Icon(
                      CupertinoIcons.arrow_2_circlepath,
                      color: CupertinoColors.white,
                      size: context.rs(18),
                    ),
                  ),
                  SizedBox(width: context.rs(12)),
                  Text(
                    'Restore Purchases',
                    style: AppTypography.boldStyle(
                      fontSize: context.rs(15),
                      color: const Color(0xFF261D32),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: context.rs(8)),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LinkText('Privacy Policy', onTap: () {}),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.rs(8)),
                  child: Text(
                    '•',
                    style: AppTypography.semiBoldStyle(
                      fontSize: context.rs(14),
                      color: const Color(0xFF9F98AA),
                    ),
                  ),
                ),
                _LinkText('Terms of Use', onTap: () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LinkText extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _LinkText(this.text, {required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PressButton(
      onPressed: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.rs(6)),
        child: Text(
          text,
          style: AppTypography.boldStyle(
            fontSize: context.rs(12),
            color: AppColors.purple,
          ),
        ),
      ),
    );
  }
}

class _PlanTicket extends StatelessWidget {
  final VoidCallback onTap;

  const _PlanTicket({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.rs(14)),
      child: PressButton(
        onPressed: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: context.rs(110)),
          child: CustomPaint(
            painter: _TicketPainter(
              radius: context.rs(16),
              notchRadius: context.rs(10),
              dash: context.rs(4),
              gap: context.rs(3),
              strokeWidth: context.rs(1.5),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: context.rs(18),
                vertical: context.rs(16),
              ),
              child: Center(
                child: Row(
                  children: [
                    Expanded(
                      flex: 7,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.rs(14),
                          vertical: context.rs(8),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2D1B00),
                          borderRadius: BorderRadius.circular(context.rs(12)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'No plan yet',
                              style: AppTypography.semiBoldStyle(
                                fontSize: context.rs(12),
                                color: const Color(0xFFFFD464),
                              ),
                            ),
                            SizedBox(height: context.rs(4)),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Try Free for 7 days',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.boldStyle(
                                      fontSize: context.rs(16),
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                ),
                                Icon(
                                  CupertinoIcons.chevron_forward,
                                  size: context.rs(16),
                                  color: CupertinoColors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: context.rs(16)),
                    Expanded(
                      flex: 2,
                      child: Icon(
                        CupertinoIcons.star_fill,
                        size: context.rs(40),
                        color: const Color(0xFF3A240C),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TicketPainter extends CustomPainter {
  final double radius;
  final double notchRadius;
  final double dash;
  final double gap;
  final double strokeWidth;

  const _TicketPainter({
    required this.radius,
    required this.notchRadius,
    required this.dash,
    required this.gap,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final midX = size.width * 0.72;
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(radius, 0)
      ..lineTo(midX - notchRadius, 0)
      ..arcToPoint(
        Offset(midX + notchRadius, 0),
        radius: Radius.circular(notchRadius),
        clockwise: false,
      )
      ..lineTo(w - radius, 0)
      ..quadraticBezierTo(w, 0, w, radius)
      ..lineTo(w, h - radius)
      ..quadraticBezierTo(w, h, w - radius, h)
      ..lineTo(midX + notchRadius, h)
      ..arcToPoint(
        Offset(midX - notchRadius, h),
        radius: Radius.circular(notchRadius),
        clockwise: false,
      )
      ..lineTo(radius, h)
      ..quadraticBezierTo(0, h, 0, h - radius)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFDF7D), Color(0xFFEDB02B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Offset.zero & size),
    );

    final dashPaint = Paint()
      ..color = const Color(0x669B670B)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    for (var y = radius; y < h - radius; y += dash + gap) {
      canvas.drawLine(Offset(midX, y), Offset(midX, y + dash), dashPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TicketPainter old) =>
      old.radius != radius ||
      old.notchRadius != notchRadius ||
      old.dash != dash ||
      old.gap != gap ||
      old.strokeWidth != strokeWidth;
}
