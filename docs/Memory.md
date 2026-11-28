# Project Memory — Kids Drawing App

This is durable project context for contributors and AI coding assistants. Update it when decisions change. Do not turn assumptions into confirmed requirements.

**Last updated:** 2026-11-28

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
- Paint engines (one `DrawingTool` per pen): `PencilTool`, `MarkerTool`, `GlitterTool` in `core/tools/`. Owned and routed by `StationaryTools` (`toolForCategory` via `CategoryModel.brushType`, `toolFor(BrushType)`); `DrawingViewModel` exposes `tool` and `toolFor` for active category and per-stroke replay.
- Stick catalogs only (not paint): `PencilTools`, `MarkerTools`, `GlitterTools` + `StationaryTools` / `CategoryTools` in `core/tools/stationary/`. `selectCategory` sets `brushConfig.type`; each stroke persists `brush.type` in JSON (`StrokesJsonCodec`).
- `LayerManager` bakes all committed paint to `_paintImage` and a coarser `_glitterMask` (glitter adds, later non-glitter strokes cut). Shimmer is drawn live over mask + active glitter stroke through `DrawingTool.paintShimmer`; `WorkspaceCanvas` runs `shimmerTicker` (20 fps) when committed **or** active strokes use glitter (committed-glitter flag cached on stroke-list changes, not rescanned per finger move); `layerManager.paint(..., shimmerSeconds:)`; thumbnails/export pass none (still).
- Glitter **paint**: opaque round tip (no build-up on overlap) + procedural sparkle tile fixed to the page (srcATop). Stick colors in `GlitterTools` are sampled from each `assets/stationary/glitter/*.png` tube. `PaintColor`/`StationaryModel` hold a `colors` list; several colors blend along the stroke.
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
- Later (sounds done 2026-11-22, and music was added after all): sounds, bucket/crayon/wand/brush paint engines, stroke eraser, full export UX, padlocked colors, settings polish (e.g. live background toggle in UI). Optional: pencil scribble density tuning. Padlocked colors are out of the first build.

## 3. Code layout (summary)

**Canonical file map:** [`Architecture.md` §3](Architecture.md#3-codebase-map-live-tree) — every `lib/**/*.dart` file with a one-line description. Update §3 when `lib/` structure changes.

- **Composition:** `lib/main.dart` — Floor DB + v2 migration, catalog seed, `AppSound` preload, `MultiProvider` (`DrawingViewModel`, `GalleryViewModel`, `GenreViewModel`, `SettingViewModel`, `AppSound`), `CupertinoApp` with `SoundRouteObserver` → `SplashScreen`.
- **Presentation:** `lib/app/` — `splash`, `genre`, `gallery`, `drawing`, `setting`, `parent_gate` (screens + feature widgets).
- **State:** `lib/state/<feature>/` — ViewModels only.
- **Engine & tools:** `lib/core/engine/`, `lib/core/tools/` (`stationary.tools.dart`, `*.drawing.tool.dart`, textures, stationary catalogs). Engine does not import concrete tools.
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
- Pencil, marker, glitter: implemented (`StationaryTools` engines, category rail, per-stroke `toolFor`). Pencil look unchanged from original tuned engine; marker semi-opaque dabs; glitter opaque sparkle band with live shimmer (while drawing and after).
- Color-balls and letters show in a 2-column `ToolGrid` (`CategoryModel.grid` / `tiled`).
- Engines for every category (2026-11-22), tuned against the reference video: crayon (waxy, ragged edges, smooth inside), brush (opaque, bristle streaks), marker (crisp even translucent stroke), watercolor (light wash, wet edge, fine grain), spray (dot spatter), bucket (color balls; tap fills a region or the whole background, gradient for multi-color balls), pattern (tape; page-fixed designer tile), sticker (letters; above outlines, follows the finger until lift, size = brush size × 4.5).
- Crayon has no paper grain: the user wants it smooth inside, with no white specks (2026-11-22).
- Marker and watercolor are matched to the user's reference screenshots (`~/Downloads/marker-color-usage-ss.png`, `water-color-pen-ss.png`), measured by pixel: marker ~72% alpha, normal blend, 2-3 px crisp edge, flat inside; watercolor ~38% in the middle, normal blend, soft ~15-20 px edge with a darker band just inside, fine tonal grain (sd ~5, no white holes). Checked in the simulator 2026-11-22: marker orange on white #F7A047 with a 2 px edge (dab spacing 0.06 keeps the edge smooth); watercolor middle ~37% with grain sd ~4 and a darker band inside the edge. Opacity alone did not fix the dull look: the wide blurry tip rim and the missing grain mattered as much.
- Blank paper is a `background` region, so clip-mode strokes and bucket fills work there. The bucket ignores clip mode; stickers are never clipped.
- Pattern tiles and stickers are image assets loaded by `TextureLibrary` before use (`selectTool` awaits it; reopening an artwork preloads its strokes' textures).
- Glitter animation: 3 glint tile sets fading in turn (1.2 s period), masked to visible glitter. Shader twinkle (`glitter.frag`) was replaced 2026-11-21. Burst rewritten 2026-11-21: pops from the lift point in screen space.
- Code style (user preference, 2026-11-21): small named functions with early returns; no ternaries or `&&`/`||` chains in new code; magic numbers as named constants. Tools share `DrawingTool.stampDabs` + `StrokeDabber.isEmpty` instead of copying stamp code.
- Genre live background: implemented; `liveBackgroundOn` pref only (no settings panel toggle yet).
- Region coloring, density, stick colors, undo/redo, pinch/burst, clear-all confirm, stroke persistence + thumbnail bake (`saveProgress`, `ArtworkThumbnailBaker`): implemented. Device FPS/latency not measured.
- Code layout: MVVM (`lib/app/`, `core/`, `state/`, `data/`, `types/`). Live composition is `main.dart` `MultiProvider` (not `app.dependencies.dart`).
- Sound, voice and haptics (2026-11-22, updated 2026-11-28): implemented behind one `AppSound` facade in `core/audio/`. `flutter_soloud` for all audio — effects, music, ambience and voice clips. No TTS dependency.
- Voice text lives on the models: `GenreModel.voice` and `CategoryModel.voice` (pools of lines, one picked at random and never the same twice running), `StationaryModel.voice` (defaults to the stick's name), and a `voice` column on the artwork row. Voice translations come from the `catalog_translations` DB table (synced from Supabase), not from bundled JSON packs.
- **Voice is recordings only (2026-11-28).** `flutter_tts` fully removed. The app plays pre-recorded clips — bundled in `assets/voice/en/`, or downloaded into `<app support>/voice/<lang>/` by `CatalogSyncService._downloadVoiceClips`. When no clip exists, silence (no fallback). Clips are produced outside this repo via ElevenLabs, uploaded through the admin dashboard. `VoiceClips.fileNameFor` is the cross-system filename contract (slug + FNV-1a hash).
- `VoiceClips.fileNameFor` is the **contract** between the app, the renderer and the admin dashboard the user is building: slug of the line plus an FNV-1a hash. Because the name is a pure function of the text, a clip rendered on a server and downloaded to a phone needs no index, manifest or database column to be found. Do not change it on one side only.
- Plan for artwork (user, 2026-11-22): ten defaults ship with the app and their clips; everything else is pulled from Supabase once a day with its clip, uploaded through an admin dashboard that generates the voice with ElevenLabs. The app is **offline** — it never calls a speech API at runtime. The sync itself is not built yet; the clip lookup is ready for it.
- Background audio is two different things: an app-wide music loop (`puppy_playtime`) on splash and the genre hub, and, inside a genre, a pool of short ambience clips (birds, rain, a school bell) played at random 8-20 s gaps, which **replaces** the music. Both stop on the drawing screen so the canvas belongs to the tool sounds. A pool of 2 s clips is cheaper than a music loop per genre and does not get repetitive. Ambience follows the **Music** toggle and the music volume.
- Every tappable thing is `PressButton` (`core/ui/button/`), which owns the press sound, the haptic and the hold timing; `CircleButton`, `RoundedButton` and `PillButton` compose it. This also fixed the Vibrations setting, which until then controlled nothing while `CircleButton` buzzed unconditionally.
- **One sound per click (user, 2026-11-22):** `tap_in` for anything forward — a screen opens, something is picked — and `tap_out` for leaving: back, close, cancel (`PressSound.enter` / `.exit`). It replaced the press-down/press-up pair and the separate nav clips. The sound fires on the confirmed tap, not on tap-down, because tap-down also fires when a scroll starts and would click on every flick of the genre carousel. `AppSound` drops a repeat of the same clip within 150 ms, so a back button and the route it pops sound once.
- The music never played before round 2: the stored and default track id was `confetti_party`, which has no file, and the one real track was not even listed in the Music panel. A track with no file now plays `puppy_playtime` (`MusicPlayer._fallbackTrackId`), so every row in the panel makes a sound and a real file takes over the moment it is dropped in. The iOS audio category also moved from `ambient` to `playback`, because `ambient` handed the whole app to the ring switch.
- Floor went to v2 (2026-11-22) to add the artwork `voice` column; `ArtworkCatalogSeeder` backfills existing rows, so an installed app is not left silent after the migration.
- Settings were already persisted and unused; `SettingViewModel` now pushes every audio preference into `AppSound`. Music volume drives music and ambience only — effects play at a fixed 0.8 and voice at full, so a quiet music setting never makes the voice inaudible. Music ducks to 35% while a line is spoken.
- A missing audio file is never an error: the players remember it and stay silent, so the app works while clips are still being authored. The manifest of what ships and what is still needed is [`Sound-Assets.md`](Sound-Assets.md).
- Remote catalog (designed 2026-11-23, not built): genres and artwork come from Supabase, uploaded through an admin dashboard the user is building; the app syncs once a day into its local Floor database. **Remote is the source of truth and the Dart seeds are the offline fallback** — they install only when nothing is local and no sync has succeeded. Downloaded audio is permanent, not a cache. The child's colouring never leaves the device. Full spec: [`Admin-Dashboard.md`](Admin-Dashboard.md).
- Schema decisions worth not re-litigating: **one `translations` table** holding text and its audio together for every localized value, owned by an exclusive arc (`genre_id` xor `artwork_id`) so a single table keeps real foreign keys; `position` on that row makes voice-line pools free; a `languages` table because 26+ languages are coming and Arabic needs `direction`; **no users or devices table** — there is nothing for it to hold and a device id on a server is a COPPA/GDPR-K liability in a kids app; **`slug` immutable once published**, enforced by a trigger, because a child's strokes are keyed to `artworkKey`.
- Clip filenames are a cross-system contract (`VoiceClips.fileNameFor`): slug + FNV-1a hash, language in the folder, never in the name. The dashboard's JavaScript copy was checked against all 106 names the Dart produces.
- Remote artwork JSON format (2026-11-28): seed artworks use `lines` (array of stroke paths) + `outline`; remote/Supabase artworks use `linework` (single filled path with `fillRule: "evenodd"`) + `viewBox` with an origin offset (e.g. `"0 -256 1536 1536"`). `JsonArtworkLoader` now handles both. `ColoringArtwork.lineworkPaths` holds the filled outlines; `LayerManager._recordOutlines` draws them as fills when present, falls back to stroked outlines for seed art.
- Voice download fix (2026-11-28): `_downloadVoiceClips` was gated on `audioSha256 IS NOT NULL` in the `withAudioInLanguage` DAO query, but remote translation rows have `audioPath` set while `audioSha256` is NULL. Changed to gate on `audioPath IS NOT NULL AND audioPath != ''`. This was the root cause of voice clips never being downloaded from Supabase.
- `flutter_tts` fully removed (2026-11-28): no TTS dependency remains. Voice is recordings only — silent when no clip exists.
- `VoiceLines` deleted (2026-11-28): loaded JSON translation packs from `assets/voice/<lang>.json` that never existed. Translations come from the `catalog_translations` DB table via sync. Dead code removed.
- `AppSound` speech chain simplified (2026-11-28): was `_speakPool` → `_speakLines` → `_sayOne` (3 layers). Now `_speakFromPool` → `_playVoice` (2 layers). `VoiceLines` dependency removed entirely.
- Not implemented: the remaining audio files (burst, the ten stroke sounds, the ambience clips, four of five music tracks), stroke eraser, padlocked colors, full export/share product flow, framework benchmark (Flutter vs RN + Skia).

## 10. AI/developer working rules
Read the project docs before substantial changes. **Start with `Architecture.md` §3** for file locations and reuse. Inspect files before overwriting. Follow `docs/Architecture.md` and `.cursor/rules/` (including `doc-tree.mdc`). Update §3 when `lib/` structure changes in the same task. Provide complete code, not references to code never supplied. Avoid unnecessary dependencies. Work in runnable milestones. Do not claim performance targets are met without measurements. Keep both prototypes behaviorally aligned. Record decisions and unresolved questions here. Claude: see root [`CLAUDE.md`](../CLAUDE.md).
