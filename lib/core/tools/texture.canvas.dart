import 'dart:ui' as ui;

/// Turns drawing code into a brush texture image, once, at tool start-up.
class TextureCanvas {
  const TextureCanvas._();

  /// Records [draw] and returns it as a [width] x [height] pixel image.
  static ui.Image render(
    double width,
    double height,
    void Function(ui.Canvas canvas) draw,
  ) {
    final recorder = ui.PictureRecorder();
    draw(ui.Canvas(recorder));
    final picture = recorder.endRecording();
    final image = picture.toImageSync(width.toInt(), height.toInt());
    picture.dispose();
    return image;
  }
}
