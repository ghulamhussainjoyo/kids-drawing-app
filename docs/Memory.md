# Project Memory — Kids Drawing App

This is durable project context for contributors and AI coding assistants. Update it when decisions change. Do not turn assumptions into confirmed requirements.

**Last updated:** 2026-11-20

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
- Splash is the home route. Navigation: Splash → **Genre** → Gallery → Drawing.
- Drawing session: `MultiProvider` / `ChangeNotifierProvider` in `lib/main.dart` creates one `DrawingViewModel` at app launch. Gallery calls `selectArtwork(title)` then pushes the drawing screen with no artwork argument. Stick rail calls `selectTool` / `selectCategory`. Density slider calls `setDensity`. The drawing screen is View-only (`Provider.of` listen: false + `ListenableBuilder` inside `NativeDeviceOrientationReader`).
- Live app shell is `AppWidget` in `lib/main.dart`.
- Active drawing UI: `lib/app/drawing/screen/drawing.screen.dart` with `widgets/canva/workspace.canvas.dart` / `workspace.painter.dart`.
- Paint engines (one `DrawingTool` per pen): `PencilTool`, `MarkerTool`, `GlitterTool` in `core/tools/`. Routed via `DrawingToolKit` (`forCategory` / `forType`); `DrawingViewModel` exposes `tool` and `toolFor` for active category and per-stroke replay.
- Stick catalogs only (not paint): `PencilTools`, `MarkerTools`, `GlitterTools` + `StationaryTools` / `CategoryTools` in `core/tools/stationary/`. `selectCategory` sets `brushConfig.type`; each stroke persists `brush.type` in JSON (`StrokesJsonCodec`).
- `LayerManager` bakes pencil/marker to `_paintImage`; glitter to separate `_glitterImage`. Active glitter is rasterized per frame in stroke bounds and twinkles with the same shader as baked glitter. Glitter twinkle: `GlitterTwinkle` + `shaders/glitter.frag`; `WorkspaceCanvas` runs `glitterTicker` when committed **or** active strokes use glitter; `layerManager.paint(..., time:)` drives the shader.
- Glitter **paint** grain: `GlitterTextures` tries `assets/brushes/glitter-texture.svg` (bright-speck threshold, rejected if too solid) else procedural speck tile; `stampCell` 80; tint via `BlendMode.modulate`. `assets/stationary/glitter/*.png` is rail UI only (`GlitterTools`). Do not use removed `assets/glitter/stamps/`.
- Genre hub: `GenreLiveBackground` (animated PNG scenery) behind carousel; gated by `liveBackgroundOn` in `SettingsRepository` / `SettingViewModel` (default on). Settings UI toggle for live background not wired yet.
- Settings: parent gate on genre hub → `SettingDialog`; panels use `SettingPanelScaffold` (fixed header + scroll body). Persistence: `SettingsRepository` in `data/`, `SettingViewModel` in `state/setting/`.
- Brush size: left density slider → `DrawingViewModel.setDensity` → size `12 + density * 44` for subsequent strokes.
- Eraser button: full-screen clear-all confirm (NO dismisses, YES calls `clearAll`). Not a stroke eraser brush yet.
- `DrawingViewModel` owns catalog access, `selectedArtworkId`, `selectedTool`, `selectedCategory`, `density`, `_toolKit`, `RegionEngine`, and `LayerManager`. Gallery/catalog loads artworks from Floor + JSON seeds via `CatalogRepository`.

### Coloring behavior (confirmed 2026-11-07 from the reference image and screen recording)
- No explicit region selection. The closed part under a stroke's first touch clips that whole stroke. Forgiving part pick: a first touch inside a part always picks it, even next to its outline. A first touch on an outline, or on paper beside the art, picks the nearest part within a fingertip radius (22 screen points, converted with the current zoom). Only a touch farther than that from every part paints nothing. Inner detail lines (leaf vein, book page lines, apple shine) are not outlines: a touch on one colors the part it sits in.
- New drawing layout is landscape flex columns (controller / canvas / tools). Notch on the right widens the tools column via `NativeDeviceOrientationReader`. Do not `setState` the State that owns that reader (rebuilds restart orientation waiting and jerk the flex).
- Later strokes can cover earlier paint in the same part. Outlines stay above paint.
- On every finger lift, a burst of shapes (butterflies, stars, hearts, flowers, dots, snowflakes) appears near the stroke and fades in about 1.5 s. It is not saved and not an undo step. The Figma wand tool is a separate tool, not this burst.
- Two fingers zoom and pan only the page; painting stays accurate while zoomed; pinching out animates back to fit.
- Undo appears after the first completed stroke; redo is grey until an undo.
- Full-screen landscape with system edge gestures deferred.
- Flutter prototype first build: pencil coloring on apple-and-books, stick color choice, density brush size, undo/redo, pinch zoom/pan, finger-lift burst, Provider MVVM wiring, clear-all erase confirm.
- Later: sounds (soft drawing sound and tap sound, no music), bucket/crayon/wand/brush paint engines, stroke eraser, full export UX, padlocked colors, settings polish (e.g. live background toggle in UI). Optional: pencil scribble density tuning. Padlocked colors are out of the first build.

## 3. Code layout (summary)

**Canonical file map:** [`Architecture.md` §3](Architecture.md#3-codebase-map-live-tree) — every `lib/**/*.dart` file with a one-line description. Update §3 when `lib/` structure changes.

- **Composition:** `lib/main.dart` — Floor DB, catalog seed, `MultiProvider` (`DrawingViewModel`, `GalleryViewModel`, `GenreViewModel`, `SettingViewModel`), `CupertinoApp` → `SplashScreen`.
- **Presentation:** `lib/app/` — `splash`, `genre`, `gallery`, `drawing`, `setting`, `parent_gate` (screens + feature widgets).
- **State:** `lib/state/<feature>/` — ViewModels only.
- **Engine & tools:** `lib/core/engine/` (includes `glitter.twinkle.dart`), `lib/core/tools/` (`drawing.tool.kit.dart`, `*.drawing.tool.dart`, textures, stationary catalogs). Engine does not import concrete tools.
- **Data:** `lib/data/` — Floor, JSON artwork loaders, repository interfaces/impls (including settings).
- **Types:** `lib/types/` — domain models (strokes, regions, artwork, gallery, genre, stationary).

`core/engine` does not import concrete tools. ViewModels use repository abstractions wired in `main.dart`.

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
- App shell: `CupertinoApp` via `AppWidget` in `lib/main.dart` with `MultiProvider` (`SettingViewModel`, `GenreViewModel`, `DrawingViewModel`, `GalleryViewModel`).
- Navigation: Splash → Genre → Gallery → Drawing; settings modal from Genre (parent gate).
- Pencil, marker, glitter: implemented (`DrawingToolKit`, category rail, per-stroke `toolFor`). Pencil look unchanged from original tuned engine; marker semi-opaque dabs; glitter colored grain dabs on separate baked layer with shader twinkle (live + committed).
- Glitter animation: shader twinkle when `glitter.frag` loads; static glitter image if shader fails (`GlitterTwinkle` logs and falls back).
- Genre live background: implemented; `liveBackgroundOn` pref only (no settings panel toggle yet).
- Region coloring, density, stick colors, undo/redo, pinch/burst, clear-all confirm, stroke persistence + thumbnail bake (`saveProgress`, `ArtworkThumbnailBaker`): implemented. Device FPS/latency not measured.
- Code layout: MVVM (`lib/app/`, `core/`, `state/`, `data/`, `types/`). Live composition is `main.dart` `MultiProvider` (not `app.dependencies.dart`).
- Not implemented: sounds, bucket/crayon/wand/brush engines, stroke eraser, padlocked colors, full export/share product flow, framework benchmark (Flutter vs RN + Skia).

## 10. AI/developer working rules
Read the project docs before substantial changes. **Start with `Architecture.md` §3** for file locations and reuse. Inspect files before overwriting. Follow `docs/Architecture.md` and `.cursor/rules/` (including `doc-tree.mdc`). Update §3 when `lib/` structure changes in the same task. Provide complete code, not references to code never supplied. Avoid unnecessary dependencies. Work in runnable milestones. Do not claim performance targets are met without measurements. Keep both prototypes behaviorally aligned. Record decisions and unresolved questions here. Claude: see root [`CLAUDE.md`](../CLAUDE.md).
