import 'package:flutter/cupertino.dart';

/// Purple sky, cream ground, horizon flowers, and clothesline.
class CompleteSceneBackdrop extends StatelessWidget {
  const CompleteSceneBackdrop({super.key});

  static const Color sky = Color(0xFF4A2C6A);
  static const Color ground = Color(0xFFF3E9D8);
  static const Color flowerPetal = Color(0xFFFFC107);
  static const Color flowerCenter = Color(0xFFFF8A00);
  static const Color stem = Color(0xFF5FAE4A);

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const ColoredBox(color: sky),
        Align(
          alignment: Alignment.bottomCenter,
          child: FractionallySizedBox(
            heightFactor: 0.28,
            widthFactor: 1,
            child: const ColoredBox(color: ground),
          ),
        ),
        Align(
          alignment: const Alignment(0, -0.25),
          child: Container(
            height: 2,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            color: const Color(0xFF2A1A3A),
          ),
        ),
        Align(
          alignment: const Alignment(0, 0.38),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                // _HorizonFlower(stemHeight: 40),
                // _HorizonFlower(stemHeight: 52),
                // _HorizonFlower(stemHeight: 36),
                // _HorizonFlower(stemHeight: 56),
                // _HorizonFlower(stemHeight: 44),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// class _HorizonFlower extends StatelessWidget {
//   final double stemHeight;

//   const _HorizonFlower({required this.stemHeight});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Container(
//           width: 22,
//           height: 22,
//           decoration: const BoxDecoration(
//             color: CompleteSceneBackdrop.flowerPetal,
//             shape: BoxShape.circle,
//           ),
//           child: Center(
//             child: Container(
//               width: 8,
//               height: 8,
//               decoration: const BoxDecoration(
//                 color: CompleteSceneBackdrop.flowerCenter,
//                 shape: BoxShape.circle,
//               ),
//             ),
//           ),
//         ),
//         Container(
//           width: 3,
//           height: stemHeight,
//           color: CompleteSceneBackdrop.stem,
//         ),
//       ],
//     );
//   }
// }
