import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kids_drawing_flutter/app/genre/widget/genre.carousel.dart';
import 'package:kids_drawing_flutter/app/parent_gate/utils/parent.gate.dart';
import 'package:kids_drawing_flutter/app/setting/screen/setting.screen.dart';

class GenreScreen extends StatelessWidget {
  const GenreScreen({super.key});
  double getHorizontalPadding(double width) {
    return width < 360 ? 16.0 : 24.0;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: 12,
              horizontal: getHorizontalPadding(constraints.maxWidth),
            ),
            child: Stack(
              children: [
                // Carousel area
                Positioned(
                  // Room for the arched title above the focused circle.
                  top: 50,
                  left: 0,
                  right: 0,
                  bottom: 40,
                  child: GenreCarousel(),
                ),

                // Top controls
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      CupertinoButton(
                        onPressed: () async {
                          final granted = await ParentGate.request(context);
                          if (!context.mounted || !granted) return;
                          showDialog<void>(
                            context: context,
                            barrierColor: const Color(0x73000000),
                            builder: (_) => const SettingDialog(),
                          );
                        },
                        padding: EdgeInsets.zero,
                        child: const Icon(CupertinoIcons.settings),
                      ),
                      const Spacer(),
                      const CupertinoButton(
                        onPressed: null,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Text('Try free for 7 days'),
                      ),
                    ],
                  ),
                ),
                // Bottom controls
                const Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Row(
                    children: [
                      Spacer(),
                      CupertinoButton(
                        padding: EdgeInsets.zero,
                        onPressed: null,
                        child: Text('Bottom left'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
