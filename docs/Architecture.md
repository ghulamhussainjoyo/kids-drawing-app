# Architecture — Kids Drawing App

**Status:** Initial technical baseline  
**Platforms:** iOS and Android  
**Prototype strategy:** Flutter first, then an equivalent React Native + Skia prototype. No production framework decision is made until both are benchmarked.

## 1. Architectural goals
- Natural, responsive freehand drawing.
- Accurate region-constrained painting with no bleed.
- Rendering independent from presentation widgets.
- Editable strokes/layers, undo/redo and offline persistence.
- High-resolution export.
- Measurable performance on physical devices.

## 2. Layered architecture
1. **Presentation:** screens, toolbar, brush picker, palette, gestures and accessibility.
2. **Application/state:** drawing session, commands, undo/redo, selection and document lifecycle.
3. **Domain:** document, layer, region, stroke and brush models.
4. **Rendering engine:** input sampling, stroke construction, brush rendering, clipping, compositing, caching and hit testing.
5. **Infrastructure:** artwork loading, persistence, asset decoding and export.

The UI sends normalized input and commands to the engine. It must not implement brush geometry or region clipping.

## 3. Folder structure (MVVM)

Create a folder only when the first file needs it. Forbidden names: `utils`, `helpers`, `common`, `misc`, `shared`. Existing `lib/features/models`, `lib/features/state`, `lib/features/engine`, and `lib/features/data` paths are legacy; leave them in place until a refactor is approved. AI coding rules live in `.cursor/rules/`.

```text
lib/
  main.dart                         # WidgetsFlutterBinding, MultiProvider, AppWidget (live CupertinoApp)
  core/                             # imports nothing from app, state, features
    ui/
      theme/                        # colors, spacing, text styles, theme
      widgets/                      # widgets used by two or more features
    engine/                         # shared drawing logic used by every tool
    tools/                          # one DrawingTool class per paint engine + stick catalogs
      drawing.tool.dart
      pencil.drawing.tool.dart      # PencilTool paint engine
      pencil.tool.dart              # PencilTools stick catalog (colors)
      marker.tool.dart              # MarkerTools stick catalog
      stationary.tools.dart         # StationaryTools categories
    type/
      category.model.dart
    storage/                        # abstract interfaces only; no concrete DB yet
  state/                            # ViewModels (ChangeNotifier); mirrors feature names
    drawing/
      drawing.view-model.dart       # DrawingViewModel (session owner)
  data/                             # never imports state, features, or Flutter widgets
    models/
    api/                            # future Dio clients
    local/
      artwork/
    repositories/
      artwork/
  features/
    splash/
    category/
    gallery/
    drawing/
      screen/
        drawing.screen.dart.dart      # active DrawingScreen
        erase.confirm.screen.dart
      widgets/
        workspace.canvas.dart
        workspace.painter.dart
        tools/
assets/
docs/
```

Placement: `screen/` is the route widget only. Route widgets use `CupertinoPageScaffold` and navigate with `CupertinoPageRoute`. Do not use `Scaffold`, `AppBar`, or `ElevatedButton` under `CupertinoApp`. Shared drawing logic lives in `core/engine`. Each paint engine is one `DrawingTool` class in `core/tools`. Stick catalogs (`PencilTools`, `MarkerTools`) are separate from paint engines. Do not add empty tool or API files.

**Live composition root:** `lib/main.dart` creates `DrawingViewModel` inside `MultiProvider` / `ChangeNotifierProvider` and hosts `AppWidget`. Gallery calls `selectArtwork`; stick rail calls `selectTool` / `selectCategory`; density slider calls `setDensity`. `app/app.dependencies.dart` may become the wire-up later; do not claim it is live today.

### MVVM mapping

```mermaid
flowchart TD
    Main["main.dart MultiProvider"] --> AppWidget
    Main --> ViewModel
    AppWidget --> View
    View["features/drawing/screen"] -->|"Provider.of + ListenableBuilder"| ViewModel["state/drawing DrawingViewModel"]
    View --> Widgets["features/drawing/widgets"]
    View --> CoreUi["core/ui"]
    ViewModel --> Repository["ArtworkRepository"]
    ViewModel --> Engine["RegionEngine LayerManager"]
    ViewModel --> Tools["DrawingTool / PencilTool"]
    Tools --> Engine
    ViewModel --> Models["data/models"]
    Repository --> Local["data/local"]
    Repository --> Models
```

- Live shell and composition: `main.dart` (`MultiProvider` + `AppWidget`).
- `DrawingViewModel` owns session state: `artworkRepository`, `selectedArtworkId`, `selectedTool`, `selectedCategory`, `density`, active `DrawingTool`, `RegionEngine`, and `LayerManager`. The drawing screen does not construct engines or pass artwork/tool into the route.
- A screen may import `state/<its feature>/`, its own `widgets/`, `core/ui/`, and `data/models`. It never imports `data/api`, `data/local`, repository implementations, or `core/storage`.
- A ViewModel imports `foundation.dart` and `dart:ui` only from Flutter for UI types. Prefer repository interfaces; the current app constructs `ArtworkRepositoryImpl` inside `DrawingViewModel` until a fuller composition root exists.
- `data/` never imports `state/`, `features/`, `material.dart`, or `cupertino.dart`.
- `core/` never imports `app/`, `state/`, or `features/`. Engine may use `data/models` only.
- `core/tools` may import `core/engine`. The engine never imports a concrete tool. New paint tool = new `DrawingTool` class; no new `switch` in the engine or ViewModel for tool behavior.
- Offline-first: the repository reads local first and syncs with the API when APIs exist. The ViewModel does not know which source answered.

## 4. Core domain objects
- **DrawingDocument:** stable ID, schema version, artwork ID, logical canvas dimensions, ordered layers and metadata.
- **DrawingLayer:** ID, name, type, visibility, opacity, blend mode, order and content.
- **DrawingRegion:** stable ID, artwork ID, closed path/mask, bounds, z-order, paintable flag and optional semantic name.
- **DrawingStroke:** ID, layer ID, brush snapshot, color, points and optional region ID.
- **BrushConfig:** type, color, size, opacity, spacing, hardness/texture parameters and dynamics.

Point samples may include position, timestamp, pressure, tilt and orientation when available.

## 5. Coordinate spaces
Use explicit screen, canvas and artwork coordinate spaces. Convert screen input to canvas coordinates using the inverse canvas transform. Store strokes in canvas coordinates. Store region paths in artwork coordinates and transform them consistently. Never persist raw screen coordinates.

## 6. Rendering pipeline
1. Receive pointer/stylus samples.
2. Convert to canvas coordinates.
3. Filter noisy samples while preserving corners and timing.
4. Construct a path or brush-dab sequence.
5. Render to the active paint layer.
6. Apply the selected region clip when region mode is active.
7. Composite paint layers.
8. Draw artwork outlines/foreground details above paint.
9. Present the frame.

Region clipping must use the actual closed path or mask, not a rectangular bounding box.

## 7. Layers and artwork
Typical back-to-front stack:
1. Background.
2. Paint layers.
3. Stickers/objects.
4. Artwork outline/foreground details.

Each independently paintable artwork part must be a closed vector path or an equivalent mask with a stable ID. Flattened PNG/JPG alone is insufficient for precise region clipping unless accompanied by separately authored masks.

## 8. State and history
A completed stroke is one undo operation; do not create history entries for every pointer move. Erase, fill, sticker and layer changes are also discrete operations. Define history memory limits and compaction before large sessions.

## 9. Persistence and offline behavior
Persist editable stroke data and document metadata locally. Version the schema, use atomic writes, cache artwork locally, and autosave at safe transaction boundaries. Core drawing must work without network access.

## 10. Export
Render at requested pixel dimensions, independently of screen resolution. Support transparent or solid backgrounds. Composite all visible layers in correct order.

## 11. Framework boundary
Flutter prototype: Flutter Canvas/CustomPainter and platform capabilities. React Native prototype: Skia. Share domain behavior, artwork and acceptance tests; do not force identical internal implementations.

## 12. Performance and observability
Measure input-to-visible latency, frame-time distribution, missed frames, active point count, memory, CPU/GPU where available, export duration, thermal behavior and stability.
Targets (not yet measured): at least 60 FPS on agreed baseline devices, 120 FPS where supported, and an aim of under 20 ms input-to-visible latency.

## 13. Decisions to validate
Vector clips vs raster masks vs hybrid; immediate vs cached rendering; persistence format; pressure/tilt APIs; artwork complexity limits. Decide using profiling and prototype evidence.
