# Project Memory — Kids Drawing App

This is durable project context for contributors and AI coding assistants. Update it when decisions change. Do not turn assumptions into confirmed requirements.

## 1. Vision
Build a commercial children's drawing and coloring app for iOS and Android. The differentiator is expressive freehand painting with reliable region-constrained coloring, not only tap-to-fill.

## 2. Confirmed constraints and decisions
- Prototype in both Flutter and React Native + Skia.
- Implement Flutter first, then reproduce the same scope in React Native + Skia.
- Choose the production framework only after fair real-device benchmarking.
- Do not choose React Native just because the product owner has RN experience.
- Flutter SDK is installed and the app launches.
- User works in Cursor and wants complete, practical file-level implementation guidance.
- Initial Dart files were created but are empty because implementation code had not yet been provided.
- Current pubspec uses Dart constraint `^3.13.7`, Flutter SDK, `cupertino_icons`, `flutter_test` and `flutter_lints`. The first drawing milestone needs no third-party package.
- UI kit is `CupertinoApp` + `CupertinoThemeData` so Android and iOS share the same iOS-style chrome. Route widgets use `CupertinoPageScaffold` and `CupertinoPageRoute`. Do not mix Material `Scaffold` / `AppBar` / `ElevatedButton` under `CupertinoApp`.
- Splash is the home route. The drawing session (`LayerManager`, `DrawingViewModel`) is created when opening a drawing page, not at app launch.

### Coloring behavior (confirmed 2026-11-07 from the reference image and screen recording)
- No explicit region selection. The closed part under a stroke's first touch clips that whole stroke. Forgiving part pick: a first touch inside a part always picks it, even next to its outline. A first touch on an outline, or on paper beside the art, picks the nearest part within a fingertip radius (22 screen points, converted with the current zoom). Only a touch farther than that from every part paints nothing. Inner detail lines (leaf vein, book page lines, apple shine) are not outlines: a touch on one colors the part it sits in.
- Layout follows the reference app edge to edge. The notch side comes from the interface orientation on iOS or the cutout display feature on Android, and the reference app is matched on each side. Notch on the right: the whole tool column moves inward by the safe-area inset, with lavender still behind the notch. Notch on the left: the corner buttons stay put above and below the notch, and only the badge and slider in the middle band keep clear of it. Buttons and tool tiles are at least 48 px. Tool and color lists have 24 px end padding to clear rounded corners. The color rail sits on the page cream. The active-tool badge and size slider are centered on the back/palette pair. The page keeps a margin clear of the left controls and sits beside the done/settings buttons, reserving only the room those buttons need.
- Later strokes can cover earlier paint in the same part. Outlines stay above paint.
- On every finger lift, a burst of shapes (butterflies, stars, hearts, flowers, dots, snowflakes) appears near the stroke and fades in about 1.5 s. It is not saved and not an undo step. The Figma wand tool is a separate tool, not this burst.
- Two fingers zoom and pan only the page; painting stays accurate while zoomed; pinching out animates back to fit.
- Undo and the done check appear after the first completed stroke; redo is grey until an undo.
- Full-screen landscape with system edge gestures deferred.
- First build: pencil coloring on the apple-and-books page, color choice, undo/redo, zoom, finger-lift burst, and the screen states above. The size slider is shown at its default value.
- Later: sounds (soft drawing sound and tap sound, no music), then brush size and the bucket, crayon, brush, wand, marker and eraser tools. The product owner will specify brush size and those tools after the pencil works. Padlocked colors are out of the first build.

## 3. Existing Flutter paths
```text
lib/
  main.dart                         # WidgetsFlutterBinding + runApp
  app/
    app.dart                        # CupertinoApp, theme, home: SplashScreen
  core/
    ui/theme/                       # AppColors, AppTheme (CupertinoThemeData)
    engine/                         # sample, clip, bake, composite, burst, view transform
    tools/                          # DrawingTool, PencilTool
  state/drawing/drawing.viewmodel.dart
  data/
    models/                         # one type per file
    local/artwork/apple.and.books.local.dart
    repositories/artwork/
  features/splash/splash.screen.dart
  features/category/category.screen.dart
  features/drawing/
    screen/drawing.screen.dart
    widgets/                        # canvas, toolbar, palette — one widget per file
```
Legacy `lib/features/{models,state,engine,data,drawing/presentation}` was removed in the architecture rewrite.

`core/engine` and `core/tools` may import `data/models` only (not api, local, or repositories). The engine clips and bakes `DrawingStroke` / `DrawingRegion` / `ColoringArtwork`; a primitive-only engine would change every paint signature. The engine never imports `pencil.tool.dart`.

## 4. Requested capabilities
Pencil, marker, crayon, paintbrush, watercolor, airbrush/spray and eraser; smooth finger/stylus input; pressure/tilt where available; region selection and clipping; separate paint and outline layers; undo/redo; zoom/pan; stickers/backgrounds; high-resolution PNG export; offline-first operation.

## 5. Artwork requirements
Each independently paintable part needs a stable region ID and a closed vector path or equivalent mask. Decorative/open paths are non-paintable. Flattened PNG/JPG alone is not enough for accurate clipping. SVG is preferred when independent paths and stable IDs are preserved.

## 6. Figma reference
`https://www.figma.com/design/2XqvA9NcrDgQc6C6fTmIJM/kids-drawing-app?node-id=11-154&m=dev`
Inspected node `11:154`: landscape workspace, large central canvas, apple/books artwork, left editing/navigation controls, right-side color/tool controls, completion action upper-right and extra control lower-right. The visible scribbles are only a painted example, not artwork or a free-draw requirement. Only one screen has been inspected.

## 7. Agreed plan
1. Audit relevant Figma screens and interactions.
2. Agree shared prototype scope and benchmark scenarios.
3. Build Flutter prototype.
4. Build equivalent React Native + Skia prototype.
5. Test on same physical devices, OS versions, artwork and stroke sequences.
6. Compare drawing feel, clipping, latency, frame times, memory, CPU/GPU, export, heat and stability.
7. Select framework based on evidence, then build the full product.

## 8. Performance goals (not measured results)
At least 60 FPS on agreed baseline devices, 120 FPS where supported, aim under 20 ms input-to-visible latency, no visible clipping bleed, and no unbounded memory growth during long sessions. Profile release builds on physical devices.

## 9. Current status
- Flutter setup and app launch: complete.
- Documentation: initial baseline being added.
- First-build pencil coloring: implemented on the apple-and-books page, which is authored as vector paths in `lib/data/local/artwork/apple.and.books.local.dart`. There is no image asset yet. Not yet measured on devices.
- Code layout follows `docs/Architecture.md` MVVM folders (`app/`, `core/`, `state/`, `data/`, `features/`). Empty stubs (`export.engine`, `drawing.layer`) were not recreated.
- App shell is `CupertinoApp` in `lib/app/app.dart`.
- Brush size, other tools, sounds, save and export: not implemented.
- Framework benchmark: not started.

## 10. AI/developer working rules
Read the project docs before substantial changes. Inspect files before overwriting. Follow `docs/Architecture.md` and `.cursor/rules/`. Provide complete code, not references to code never supplied. Avoid unnecessary dependencies. Work in runnable milestones. Do not claim performance targets are met without measurements. Keep both prototypes behaviorally aligned. Record decisions and unresolved questions here.
