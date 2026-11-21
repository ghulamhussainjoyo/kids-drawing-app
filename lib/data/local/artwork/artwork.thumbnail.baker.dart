import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:kids_drawing_flutter/core/engine/layer.manager.dart';
import 'package:kids_drawing_flutter/core/tools/drawing.tool.dart';
import 'package:kids_drawing_flutter/types/brush.type.dart';
import 'package:kids_drawing_flutter/types/drawing.stroke.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Bakes paint + outlines into a square PNG for the gallery.
class ArtworkThumbnailBaker {
  Future<Uint8List> bakeBytes({
    required LayerManager layerManager,
    required List<DrawingStroke> strokes,
    required int revision,
    required DrawingTool Function(BrushType type) toolFor,
  }) async {
    final size = layerManager.artwork.size;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    layerManager.paint(
      canvas,
      committed: strokes,
      revision: revision,
      toolFor: toolFor,
    );
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.round(), size.round());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    picture.dispose();
    if (bytes == null) {
      throw StateError('Thumbnail bake produced no bytes');
    }
    return bytes.buffer.asUint8List();
  }

  Future<String> bake({
    required LayerManager layerManager,
    required List<DrawingStroke> strokes,
    required int revision,
    required DrawingTool Function(BrushType type) toolFor,
    required String genre,
    required String artworkKey,
  }) async {
    final png = await bakeBytes(
      layerManager: layerManager,
      strokes: strokes,
      revision: revision,
      toolFor: toolFor,
    );
    final docs = await getApplicationDocumentsDirectory();
    final folder = Directory(p.join(docs.path, 'thumbnails', genre));
    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }
    final file = File(p.join(folder.path, '$artworkKey.png'));
    await file.writeAsBytes(png, flush: true);
    return file.path;
  }
}
