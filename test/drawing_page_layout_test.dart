import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_drawing_flutter/core/engine/layer.manager.dart';
import 'package:kids_drawing_flutter/core/engine/region.engine.dart';
import 'package:kids_drawing_flutter/core/engine/stroke.renderer.dart';
import 'package:kids_drawing_flutter/core/tools/pencil.tool.dart';
import 'package:kids_drawing_flutter/data/models/brush.config.dart';
import 'package:kids_drawing_flutter/data/repositories/artwork/artwork.repository.impl.dart';
import 'package:kids_drawing_flutter/features/drawing/screen/drawing.screen.dart';
import 'package:kids_drawing_flutter/features/drawing/widgets/active.tool.badge.dart';
import 'package:kids_drawing_flutter/features/drawing/widgets/drawing.canvas.dart';
import 'package:kids_drawing_flutter/features/drawing/widgets/notch.side.dart';
import 'package:kids_drawing_flutter/features/drawing/widgets/pencil.colors.dart';
import 'package:kids_drawing_flutter/features/drawing/widgets/round.button.dart';
import 'package:kids_drawing_flutter/features/drawing/widgets/size.slider.display.dart';
import 'package:kids_drawing_flutter/features/drawing/widgets/tool.tile.dart';
import 'package:kids_drawing_flutter/state/drawing/drawing.view-model.dart';

const Size _phone = Size(844, 390);
const Size _tablet = Size(1366, 1024);
const double _notchInset = 47;
const double _epsilon = 1e-6;

Future<void> _pump(
  WidgetTester tester, {
  required Size size,
  required NotchSide side,
  double inset = 0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final repository = const ArtworkRepositoryImpl();
  final regionEngine = RegionEngine(repository.appleAndBooks());
  final pencil = PencilTool();
  final layerManager = LayerManager(
    regionEngine: regionEngine,
    strokeRenderer: StrokeRenderer(),
  );
  final viewModel = DrawingViewModel(
    artworkRepository: repository,
    regionEngine: regionEngine,
    tool: pencil,
    initialBrush: BrushConfig(
      type: pencil.type,
      paintColor: PencilColors.yellow,
      size: 36,
    ),
  );
  addTearDown(viewModel.dispose);
  addTearDown(layerManager.dispose);
  await tester.pumpWidget(
    CupertinoApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          viewPadding: EdgeInsets.symmetric(horizontal: inset),
          padding: EdgeInsets.symmetric(horizontal: inset),
        ),
        child: child!,
      ),
      home: DrawingScreen(
        viewModel: viewModel,
        layerManager: layerManager,
        notchSide: side,
      ),
    ),
  );
  await tester.pump();
}

/// On-screen rects of every button and tool tile.
List<Rect> _controlRects(WidgetTester tester, Size screen) {
  final screenRect = Offset.zero & screen;
  return [
    ...tester
        .widgetList(find.byType(RoundButton))
        .map((w) => tester.getRect(find.byWidget(w))),
    ...tester
        .widgetList(find.byType(ToolTile))
        .map((w) => tester.getRect(find.byWidget(w))),
  ].where(screenRect.overlaps).toList();
}

void _expectLayout(
  WidgetTester tester, {
  required Size screen,
  required NotchSide side,
  double inset = 0,
}) {
  final controls = _controlRects(tester, screen);
  expect(controls, isNotEmpty);
  for (final rect in controls) {
    expect(rect.width, greaterThanOrEqualTo(48 - _epsilon));
    expect(rect.height, greaterThanOrEqualTo(48 - _epsilon));
    if (side == NotchSide.right) {
      expect(rect.right, lessThanOrEqualTo(screen.width - inset));
    }
  }

  if (side == NotchSide.left) {
    // The notch sits mid-edge: the corner buttons stay put, the middle band
    // must clear it.
    for (final finder in [
      find.byType(ActiveToolBadge),
      find.byType(SizeSliderDisplay),
    ]) {
      expect(
        tester.getRect(finder).left,
        greaterThanOrEqualTo(inset - _epsilon),
      );
    }
  }

  final badge = tester.getRect(find.byType(ActiveToolBadge));
  final slider = tester.getRect(find.byType(SizeSliderDisplay));
  expect(badge.center.dx, closeTo(slider.center.dx, 1));

  final page = tester
      .widget<DrawingCanvas>(find.byType(DrawingCanvas))
      .pageRect;
  expect(page.width, greaterThan(0));
  expect(page.left, greaterThanOrEqualTo(slider.right + 16));
  final settings = tester.getRect(find.bySemanticsLabel('Settings'));
  expect(settings.left, greaterThan(page.right));
  for (final rect
      in tester
          .widgetList(find.byType(RoundButton))
          .map((w) => tester.getRect(find.byWidget(w)))) {
    expect(
      page.overlaps(rect),
      isFalse,
      reason: 'page $page overlaps control $rect',
    );
  }
}

void main() {
  testWidgets('phone with the notch on the right', (tester) async {
    await _pump(
      tester,
      size: _phone,
      side: NotchSide.right,
      inset: _notchInset,
    );
    _expectLayout(
      tester,
      screen: _phone,
      side: NotchSide.right,
      inset: _notchInset,
    );
  });

  testWidgets('phone with the notch on the left', (tester) async {
    await _pump(tester, size: _phone, side: NotchSide.left, inset: _notchInset);
    _expectLayout(
      tester,
      screen: _phone,
      side: NotchSide.left,
      inset: _notchInset,
    );
  });

  testWidgets('phone without a notch', (tester) async {
    await _pump(tester, size: _phone, side: NotchSide.none);
    _expectLayout(tester, screen: _phone, side: NotchSide.none);
  });

  testWidgets('tablet', (tester) async {
    await _pump(tester, size: _tablet, side: NotchSide.none);
    _expectLayout(tester, screen: _tablet, side: NotchSide.none);
  });
}
