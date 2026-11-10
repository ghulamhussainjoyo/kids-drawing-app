import 'dart:math' as math;
import 'dart:ui' show DisplayFeatureType;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'notch.side.dart';

/// Builds with the current notch side and how far content on that side must
/// move inward to clear the cutout.
///
/// iOS reports equal left and right safe-area insets in landscape, so the side
/// comes from the native interface orientation over [_channel]. Android
/// reports the cutout's real bounds as a display feature.
class NotchSideBuilder extends StatefulWidget {
  const NotchSideBuilder({super.key, required this.builder, this.side});

  final Widget Function(BuildContext context, NotchSide side, double inset)
      builder;

  /// Fixed side; when null the side is detected from the device.
  final NotchSide? side;

  @override
  State<NotchSideBuilder> createState() => _NotchSideBuilderState();
}

class _NotchSideBuilderState extends State<NotchSideBuilder> {
  static const MethodChannel _channel = MethodChannel('kids_drawing/notch');

  NotchSide _iosSide = NotchSide.none;

  bool get _isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    if (!_isIOS) return;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'notchSideChanged') {
        _setIosSide(call.arguments);
      }
    });
    _queryIosSide();
  }

  Future<void> _queryIosSide() async {
    try {
      _setIosSide(await _channel.invokeMethod<String>('getNotchSide'));
    } on PlatformException catch (error) {
      debugPrint('Notch side unavailable: $error');
    } on MissingPluginException catch (error) {
      debugPrint('Notch side unavailable: $error');
    }
  }

  @override
  void dispose() {
    if (_isIOS) _channel.setMethodCallHandler(null);
    super.dispose();
  }

  void _setIosSide(Object? value) {
    final side = switch (value) {
      'left' => NotchSide.left,
      'right' => NotchSide.right,
      _ => NotchSide.none,
    };
    if (mounted && side != _iosSide) setState(() => _iosSide = side);
  }

  NotchSide _androidSide(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    for (final feature in MediaQuery.displayFeaturesOf(context)) {
      if (feature.type != DisplayFeatureType.cutout) continue;
      final centerX = feature.bounds.center.dx;
      if (centerX < width / 3) return NotchSide.left;
      if (centerX > width * 2 / 3) return NotchSide.right;
    }
    return NotchSide.none;
  }

  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.viewPaddingOf(context);
    final inset = math.max(padding.left, padding.right);
    final side = widget.side ?? (_isIOS ? _iosSide : _androidSide(context));
    return widget.builder(context, inset > 0 ? side : NotchSide.none, inset);
  }
}
