# Project Rules — Kids Drawing App

These rules apply to developers and AI coding assistants.

## 1. Before coding
1. Read `Memory.md`, `PRD.md`, `TRD.md`, `Architecture.md`, `Design.md` and `UI-UX.md`.
2. Inspect the repository and files before editing.
3. Confirm real paths/imports; do not assume proposed folders exist.
4. Check installed Flutter/Dart versions and `pubspec.yaml` before dependencies.

## 2. Implementation discipline
- Work in small, runnable milestones.
- Provide complete code for files claimed as implemented.
- Do not claim to have edited the user's local Cursor workspace; provide code or artifacts the user can apply.
- Do not overwrite unrelated files or rename/move files without explanation and approval.
- Separate presentation, state, domain models and rendering.
- Keep brush geometry and clipping out of UI widgets.
- Prefer SDK APIs for the first prototype; justify added packages.
- Do not implement advanced brushes before basic drawing, clipping and history are correct.

## 3. Product invariants
- Region-mode strokes never paint outside the selected region.
- Artwork outlines remain visible above paint.
- One completed stroke is one undo operation.
- Eraser affects paint, not original artwork outlines.
- Convert screen coordinates to canvas coordinates before storing points.
- Zoom/pan never distorts saved strokes.
- Region and free-draw modes are explicit and visible.
- Local artwork remains usable offline.

## 4. Code quality
Simple, readable Dart comes first. A teammate must follow `core/engine` top to bottom without a walkthrough. Dense or clever code is a bug. Use domain words (stroke, region, layer, dab, tool). Prefer early returns, `for` loops, named locals, and obvious types (`List<DrawingStroke>`, not `List<T>`). Comment only the why. Do not build mini-frameworks, registries, mixins, `typedef`, or `dynamic` drawing pipelines. If two plain classes are clearer than one abstract one, write two.

Each file contains one public class, widget, or enum. Behavior lives in classes, not loose function files. Widgets are classes, not `buildX()` helpers. Soft file size ~200 lines. Follow SOLID: one reason to change per class; a new drawing tool is a new `DrawingTool` class, not a new `switch` branch; constructors receive abstractions. Wire ViewModels for the current app via `MultiProvider` in `lib/main.dart`. Prefer `lib/app/app.dependencies.dart` when that composition root is adopted; do not invent a second live wire-up.

Before creating a class or widget, search `core/ui`, `core/engine`, `core/tools`, `data/models`, and `data/repositories` and reuse what exists.

Use null safety, descriptive names, and consistent formatting. Document non-obvious coordinate/rendering decisions. Handle pointer cancellation and empty/single-point strokes. Avoid unnecessary per-frame allocations and full-document rebuilds. Add tests for geometry, history and rendering. Do not silently swallow exceptions.

AI assistants must follow `.cursor/rules/` (`simple-code.mdc`, `architecture.mdc`, `coding-standards.mdc`, `reuse-first.mdc`, and the scoped layer rules).

## 5. Performance
Never claim 60/120 FPS without measurements. Profile release/profile builds on physical devices. Measure frame time, latency, memory and export duration. Compare frameworks with identical scenarios. Optimize measured bottlenecks rather than guessing.

## 6. Artwork
Paintable regions require closed paths/masks and stable IDs. Decorative/open paths are non-paintable. Artwork and masks share a canonical coordinate system. Validate assets. A flattened image cannot be the only clipping source.

## 7. Dependencies
Before adding a package, state the requirement it solves, why SDK APIs are insufficient, platform support/maintenance considerations and compatible version. Add only what the current milestone needs.

## 8. Documentation
Update `Memory.md` when a decision is confirmed. Keep assumptions and open questions labeled. Record benchmark results with device, OS, build mode and scenario.

## 9. Framework decision
Flutter is first to prototype, not the predetermined production choice. Build equivalent React Native + Skia scope and select only after controlled real-device tests.
