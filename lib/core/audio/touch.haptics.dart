import 'package:flutter/services.dart';

/// The little buzz under a tap and under a moving stroke.
///
/// Stroke feedback is throttled: a tick per pointer sample would be a
/// constant rattle, and on iOS it would also queue up behind itself.
class TouchHaptics {
  static const _strokeGap = Duration(milliseconds: 110);
  static const _strokeDistance = 6.0;

  bool _enabled = true;
  DateTime? _lastStrokeTick;
  Offset? _lastStrokePoint;

  void setEnabled(bool value) {
    _enabled = value;
  }

  /// A button went down.
  void tap() {
    if (!_enabled) {
      return;
    }
    HapticFeedback.selectionClick();
  }

  /// Something was picked from a list.
  void select() {
    if (!_enabled) {
      return;
    }
    HapticFeedback.selectionClick();
  }

  void strokeBegan(Offset point) {
    _lastStrokeTick = null;
    _lastStrokePoint = point;
    if (!_enabled) {
      return;
    }
    HapticFeedback.selectionClick();
  }

  void strokeMoved(Offset point) {
    if (!_enabled) {
      return;
    }
    if (!_movedFarEnough(point) || !_waitedLongEnough()) {
      return;
    }
    _lastStrokePoint = point;
    _lastStrokeTick = DateTime.now();
    HapticFeedback.selectionClick();
  }

  void strokeEnded() {
    _lastStrokeTick = null;
    _lastStrokePoint = null;
  }

  bool _movedFarEnough(Offset point) {
    final last = _lastStrokePoint;
    if (last == null) {
      return true;
    }
    return (point - last).distance >= _strokeDistance;
  }

  bool _waitedLongEnough() {
    final last = _lastStrokeTick;
    if (last == null) {
      return true;
    }
    return DateTime.now().difference(last) >= _strokeGap;
  }
}
