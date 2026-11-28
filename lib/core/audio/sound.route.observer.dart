import 'package:flutter/widgets.dart';
import 'package:kids_drawing_flutter/core/audio/app.sound.dart';

/// Plays the going-in and coming-back sounds for screen changes.
///
/// Watching the navigator instead of each call site is what catches the iOS
/// edge-swipe back out of the gallery, which pops with no code of ours.
class SoundRouteObserver extends NavigatorObserver {
  final AppSound sound;

  SoundRouteObserver(this.sound);

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    // The very first screen is an arrival, not a transition.
    if (previousRoute == null) {
      return;
    }
    if (_isScreen(route)) {
      sound.pressIn();
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null && _isScreen(newRoute)) {
      sound.pressIn();
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    if (_isScreen(route)) {
      sound.pressOut();
    }
  }

  /// Dialogs (parent gate, settings) have their own sounds and should not
  /// get the page transition.
  bool _isScreen(Route<dynamic> route) {
    return route is PageRoute && !route.fullscreenDialog;
  }
}
