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
- Current pubspec uses Dart constraint `^3.13.7`, Flutter SDK, `cupertino_icons`, `provider`, `native_device_orientation`, `flutter_svg`, `flutter_test` and `flutter_lints`. Drawing still uses Flutter Canvas / CustomPainter (no third-party drawing engine).
- UI kit is `CupertinoApp` + `CupertinoThemeData` so Android and iOS share the same iOS-style chrome. Route widgets use `CupertinoPageScaffold` and `CupertinoPageRoute`. Do not mix Material `Scaffold` / `AppBar` / `ElevatedButton` under `CupertinoApp`.
- Splash is the home route. Navigation: Splash → Category → Gallery → Drawing.
- Drawing session: `MultiProvider` / `ChangeNotifierProvider` in `lib/main.dart` creates one `DrawingViewModel` at app launch. Gallery calls `selectArtwork(title)` then pushes the drawing screen with no artwork argument. Stick rail calls `selectTool` / `selectCategory`. Density slider calls `setDensity`. The drawing screen is View-only (`Provider.of` listen: false + `ListenableBuilder` inside `NativeDeviceOrientationReader`).
- Live app shell is `AppWidget` in `lib/main.dart`. `lib/app/app.dart` exists but is unused.
- Active drawing UI is `features/drawing/screen/drawing.screen.new.dart.dart` with `workspace.canvas.dart` / `workspace.painter.dart`. Legacy `drawing.screen.dart` and its widgets remain in the tree until a delete pass.
- Paint tool class: `core/tools/pencil.drawing.tool.dart` (`PencilTool`). Stick catalog: `core/tools/pencil.tool.dart` (`PencilTools`). Marker catalog exists; dedicated marker/brush `DrawingTool` paint engines are not built yet (pencil dabs still used).
- Brush size: left density slider → `DrawingViewModel.setDensity` → size `12 + density * 44` for subsequent strokes.
- Eraser button: full-screen clear-all confirm (NO dismisses, YES calls `clearAll`). Not a stroke eraser brush yet.
- ViewModel owns `artworkRepository`, `selectedArtworkId`, `selectedTool`, `selectedCategory`, `density`, `drawingTool`, `RegionEngine`, and `LayerManager`. Until gallery has real pages, `selectArtwork` still loads apple-and-books via the repository.

### Coloring behavior (confirmed 2026-11-07 from the reference image and screen recording)
- No explicit region selection. The closed part under a stroke's first touch clips that whole stroke. Forgiving part pick: a first touch inside a part always picks it, even next to its outline. A first touch on an outline, or on paper beside the art, picks the nearest part within a fingertip radius (22 screen points, converted with the current zoom). Only a touch farther than that from every part paints nothing. Inner detail lines (leaf vein, book page lines, apple shine) are not outlines: a touch on one colors the part it sits in.
- New drawing layout is landscape flex columns (controller / canvas / tools). Notch on the right widens the tools column via `NativeDeviceOrientationReader`. Do not `setState` the State that owns that reader (rebuilds restart orientation waiting and jerk the flex).
- Later strokes can cover earlier paint in the same part. Outlines stay above paint.
- On every finger lift, a burst of shapes (butterflies, stars, hearts, flowers, dots, snowflakes) appears near the stroke and fades in about 1.5 s. It is not saved and not an undo step. The Figma wand tool is a separate tool, not this burst.
- Two fingers zoom and pan only the page; painting stays accurate while zoomed; pinching out animates back to fit.
- Undo appears after the first completed stroke; redo is grey until an undo.
- Full-screen landscape with system edge gestures deferred.
- Flutter prototype first build: pencil coloring on apple-and-books, stick color choice, density brush size, undo/redo, pinch zoom/pan, finger-lift burst, Provider MVVM wiring, clear-all erase confirm.
- Later: sounds (soft drawing sound and tap sound, no music), marker/brush/bucket/crayon/wand paint engines, stroke eraser, save/export, padlocked colors, done/settings. Padlocked colors are out of the first build.

## 3. Existing Flutter paths
```text
lib/
  main.dart                         # WidgetsFlutterBinding, MultiProvider, AppWidget (CupertinoApp)
  app/
    app.dart                        # unused duplicate shell
  core/
    ui/theme/, ui/widgets/          # AppColors, AppTheme, RoundedButton, CircleButton
    engine/                         # region, layer, dab, burst, view transform
    tools/                          # DrawingTool, pencil.drawing.tool, PencilTools catalog, StationaryTools
  state/drawing/drawing.view-model.dart
  data/
    models/
    local/artwork/apple.and.books.local.dart
    repositories/artwork/
  features/splash/splash.screen.dart
  features/category/
  features/gallery/
  features/drawing/
    screen/drawing.screen.new.dart.dart   # active route
    screen/erase.confirm.screen.dart
    screen/drawing.screen.dart            # legacy
    widgets/workspace.canvas.dart
    widgets/workspace.painter.dart
    widgets/tools/                        # ControllerTools, DrawingTools, CategoryRail
```

`core/engine` and `core/tools` may import `data/models` only (not api, local, or repositories) except the ViewModel may use repository interfaces/impls for artwork load. The engine never imports a concrete tool. Stick catalog `pencil.tool.dart` is not the paint engine.

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
- App shell: `CupertinoApp` via `AppWidget` in `lib/main.dart` with `MultiProvider` → `DrawingViewModel`.
- Navigation: Splash → Category → Gallery → `DrawingScreenNew`.
- Pencil coloring on apple-and-books (vector paths in `lib/data/local/artwork/apple.and.books.local.dart`): implemented. Density brush size, stick colors, undo/redo, pinch/burst, clear-all erase confirm: implemented. Not yet measured on devices.
- Code layout follows MVVM folders (`core/`, `state/`, `data/`, `features/`). Live composition is `main.dart` MultiProvider (not `app.dependencies.dart`).
- Marker/brush paint engines, sounds, save and export: not implemented.
- Framework benchmark: not started.

## 10. AI/developer working rules
Read the project docs before substantial changes. Inspect files before overwriting. Follow `docs/Architecture.md` and `.cursor/rules/`. Provide complete code, not references to code never supplied. Avoid unnecessary dependencies. Work in runnable milestones. Do not claim performance targets are met without measurements. Keep both prototypes behaviorally aligned. Record decisions and unresolved questions here.
