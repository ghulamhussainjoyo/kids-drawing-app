/// Audio asset paths. Swapping a sound for the whole app happens here.
class SoundAssets {
  SoundAssets._();

  static const tapIn = 'assets/sounds/ui/tap_in.wav';
  static const tapOut = 'assets/sounds/ui/tap_out.wav';
  static const toolSelect = 'assets/sounds/ui/tool_select.wav';
  static const selectBell = 'assets/sounds/ui/select_bell.mp3';
  static const burstPop = 'assets/sounds/ui/burst_pop.mp3';

  /// Warmed up at startup so the first tap is not late.
  static const List<String> uiSounds = [
    tapIn,
    tapOut,
    toolSelect,
    selectBell,
    burstPop,
  ];

  /// Stroke sound of a tool category, from `CategoryModel.drawSound`.
  static String drawPath(String sound) {
    return 'assets/sounds/draw/$sound.mp3';
  }

  /// Background track, from the id stored in settings.
  static String musicPath(String trackId) {
    return 'assets/sounds/music/$trackId.mp3';
  }

  /// One genre ambience clip, from `GenreModel.ambience`.
  static String ambiencePath(String clip) {
    return 'assets/sounds/ambience/$clip.mp3';
  }
}
