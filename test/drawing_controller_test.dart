import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_drawing_flutter/core/tools/pencil.drawing.tool.dart';
import 'package:kids_drawing_flutter/data/models/brush.config.dart';
import 'package:kids_drawing_flutter/data/models/brush.type.dart';
import 'package:kids_drawing_flutter/data/models/paint.color.dart';
import 'package:kids_drawing_flutter/data/repositories/artwork/artwork.repository.impl.dart';
import 'package:kids_drawing_flutter/state/drawing/drawing.view-model.dart';

void main() {
  const yellow = PaintColor(id: 'yellow', color: Color(0xFFF9DC3C));
  const green = PaintColor(id: 'green', color: Color(0xFF3DB54A));

  late DrawingViewModel viewModel;

  setUp(() {
    viewModel = DrawingViewModel(
      artwork: const ArtworkRepositoryImpl().appleAndBooks(),
      tool: PencilTool(),
      initialBrush: const BrushConfig(
        type: BrushType.pencil,
        paintColor: yellow,
        size: 34,
      ),
    );
    addTearDown(viewModel.dispose);
  });

  void drawFrom(Offset start, List<Offset> moves) {
    if (!viewModel.beginStroke(start)) return;
    for (final move in moves) {
      viewModel.extendStroke(move);
    }
    viewModel.endStroke();
  }

  test('a stroke is locked to the region under its first touch', () {
    drawFrom(const Offset(500, 320), const [
      Offset(560, 600),
      Offset(900, 900),
    ]);

    expect(viewModel.strokes, hasLength(1));
    expect(viewModel.strokes.single.regionId, 'apple_body');
    expect(viewModel.strokes.single.points, hasLength(3));
  });

  test('first touch on an outline picks the nearest part', () {
    expect(
      viewModel.beginStroke(const Offset(478, 150), pickRadius: 30),
      isTrue,
    );
    expect(viewModel.activeStroke?.regionId, 'apple_stem');
  });

  test('first touch on blank paper paints nothing', () {
    expect(
      viewModel.beginStroke(const Offset(80, 80), pickRadius: 61),
      isFalse,
    );
    viewModel.extendStroke(const Offset(500, 320));
    expect(viewModel.endStroke(), isNull);
    expect(viewModel.strokes, isEmpty);
    expect(viewModel.hasCompletedStroke, isFalse);
  });

  test('undo and done appear only after the first completed stroke', () {
    viewModel.beginStroke(const Offset(500, 320));
    expect(viewModel.canUndo, isFalse);
    expect(viewModel.hasCompletedStroke, isFalse);

    viewModel.endStroke();
    expect(viewModel.canUndo, isTrue);
    expect(viewModel.canRedo, isFalse);
    expect(viewModel.hasCompletedStroke, isTrue);
  });

  test(
    'one stroke is one undo step; redo restores it; new stroke clears redo',
    () {
      drawFrom(const Offset(500, 320), const [Offset(520, 330)]);
      viewModel.selectColor(green);
      drawFrom(const Offset(510, 340), const [Offset(530, 350)]);

      viewModel.undo();
      expect(viewModel.strokes, hasLength(1));
      expect(viewModel.canRedo, isTrue);

      viewModel.redo();
      expect(viewModel.strokes.last.brush.paintColor.id, 'green');

      viewModel.undo();
      drawFrom(const Offset(500, 320), const [Offset(505, 330)]);
      expect(viewModel.canRedo, isFalse);
      expect(viewModel.hasCompletedStroke, isTrue);
    },
  );

  test('cancelled stroke leaves history untouched', () {
    viewModel.beginStroke(const Offset(500, 320));
    viewModel.extendStroke(const Offset(520, 330));
    viewModel.cancelStroke();
    expect(viewModel.strokes, isEmpty);
    expect(viewModel.activeStroke, isNull);
  });

  test('color changes do not mutate completed strokes', () {
    drawFrom(const Offset(500, 320), const []);
    viewModel.selectColor(green);
    expect(viewModel.strokes.single.brush.paintColor.id, 'yellow');
  });

  test('unspecified tools are not selectable yet', () {
    viewModel.selectTool(BrushType.eraser);
    expect(viewModel.brush.type, BrushType.pencil);
  });

  test('setBrushSize does not rewrite a committed stroke', () {
    drawFrom(const Offset(500, 320), const []);
    viewModel.setBrushSize(50);
    expect(viewModel.strokes.single.brush.size, 34);
    expect(viewModel.brush.size, 50);
  });

  test('clearAll empties strokes and redo', () {
    drawFrom(const Offset(500, 320), const [Offset(520, 330)]);
    viewModel.undo();
    expect(viewModel.canRedo, isTrue);

    viewModel.clearAll();
    expect(viewModel.strokes, isEmpty);
    expect(viewModel.canUndo, isFalse);
    expect(viewModel.canRedo, isFalse);
    expect(viewModel.hasCompletedStroke, isFalse);
  });
}
