# Technical Requirements Document (TRD) — Kids Drawing App

**Status:** Prototype baseline  
**Order:** Flutter prototype, then React Native + Skia parity prototype.

## 1. Technology constraints
**Flutter:** SDK installed and app launch confirmed. Current Dart constraint is `^3.13.7`. Start with SDK primitives (`Canvas`, `CustomPainter`, paths, clipping and pointer events); no third-party drawing package is needed for the first milestone.  
**React Native:** use Skia for the rendering surface. Match behavior, artwork, test scenarios and acceptance criteria. Production framework selection remains open pending benchmarks.

## 2. Input
- Capture pointer down/move/up/cancel.
- Preserve sample order and timestamps.
- Capture pressure, tilt and orientation where exposed.
- Convert input to canvas coordinates.
- Handle cancellation and lifecycle interruptions without orphaned strokes.
- Avoid rebuilding the full widget tree for every sample.
- Finger input is baseline; stylus is progressive enhancement.

## 3. Stroke model
Store ID, layer ID, brush configuration snapshot, color, opacity, size, ordered points, optional pressure/tilt/orientation/timestamp, optional region ID, and coordinate/document schema information. Keep the active stroke separate until pointer-up, then commit it as one history operation.

## 4. Rendering
Initial pencil/marker renderer: stable path-based rendering, smoothing that does not add excessive lag, visible single-point taps, round caps/joins. Keep input, state and rendering responsibilities separate.

Advanced brush evolution:
- Pencil: narrow, subtle texture/variation.
- Marker: broad, consistent, more opaque.
- Crayon: textured/dithered.
- Paintbrush: variable edge/shape and optional bristle texture.
- Watercolor: translucent pigment and soft edges.
- Airbrush: soft distributed particles/dabs.
- Eraser: affects paint layers only.

Do not build all advanced brushes before pencil/marker, clipping and history work correctly.

## 5. Region geometry and clipping
- Each paintable region is a closed path or equivalent alpha/binary mask.
- Region IDs are stable within an artwork.
- Hit testing uses transformed geometry, not bounding boxes alone.
- The region is resolved once, from the stroke's first sample: the front-most closed path containing it. Otherwise, the region nearest to the sample within a pick radius (22 screen points divided by the current view scale), measured to region-tagged edge samples taken every 2 units, plus `contains` probes on rings at half and full radius so thin parts are not missed. If no region is that close, the stroke paints nothing. Detail lines never block a pick.
- Apply the region clip to every stroke/dab.
- Antialiasing must not create visible paint outside the boundary.
- Define deterministic ownership for shared boundaries.
- Test holes, nested paths, narrow shapes, open paths and invalid geometry.
- Draw artwork outlines above paint.

## 6. Coordinates and gestures
Maintain one documented screen-to-canvas transform and its inverse. Store canvas-space points. Zoom/pan must not change stored coordinates. Define gesture arbitration: paint mode draws; navigation mode pans/zooms, or define an explicit multi-touch policy. Clamp zoom and provide fit-to-artwork.

## 7. Layers
Minimum types: background, paint, artwork outline/foreground, sticker/object. Each has ID, order, visibility, opacity and blend mode. Preserve editable strokes; any raster cache/flattening must not break history.

## 8. Undo/redo
One completed stroke equals one history operation. Erase, fill, sticker and layer changes are discrete operations. New edits after undo clear redo. Set history memory limits and preserve semantics during cache optimization.

## 9. Persistence
Persist editable strokes and document metadata. Version schema; use atomic writes; validate on load; associate saved documents with artwork ID/version; handle missing assets; do not require network for core drawing.

## 10. Export
Render at requested output dimensions, not screen resolution. Respect visibility, order, opacity and clipping. Support transparent/solid background. PNG is initial format. Validate dimensions and alignment; move expensive work off the UI thread when profiling warrants it.

## 11. Performance targets and fair benchmark
Targets: 60 FPS baseline, 120 FPS where supported, aim under 20 ms input-to-visible, no clipping bleed, stable memory during a 10-minute session.

Use identical physical devices, OS versions, artwork/masks, canvas size, brush settings and stroke sequences. Use release/profile builds and repeat runs under similar thermal/battery conditions.

Record median/p95/p99 frame time, missed-frame rate, input latency, CPU/GPU where measurable, peak/steady memory, export duration, thermal behavior, crashes and rendering defects.

## 12. Tests
**Unit:** serialization, transforms, brush config, point-in-path, undo/redo, document migration.  
**Rendering:** tap dot, straight/curved/rapid strokes, edge clipping, adjacent-region isolation, zoom mapping, eraser/outline separation, layer compositing.  
**Integration:** paint/undo/redo/save/reopen/export; app backgrounding; long sessions; offline startup.

## 13. Privacy and platform
Minimize data collection. Treat imported artwork as untrusted. Validate image dimensions and decoded memory. Request media permissions only when required by save/share flow. Complete child privacy, consent, store-policy and legal review before release.
