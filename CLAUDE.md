# Claude — Kids Drawing Flutter

Instructions for Claude Code and other assistants working in this repository.

## What this is

Children's region-constrained coloring app (Flutter prototype, iOS + Android). Freehand strokes clip to the closed part under the first touch. UI is **Cupertino-only** (`CupertinoApp`, `CupertinoPageScaffold`, `CupertinoPageRoute`). Drawing logic lives in `core/engine`; each brush is a `DrawingTool` in `core/tools/`.

## Source of truth (read in this order)

1. **Repository on disk** — `lib/`, `pubspec.yaml`. Verify paths before editing.
2. **[`docs/Architecture.md` §3](docs/Architecture.md#3-codebase-map-live-tree)** — **Canonical annotated tree** for every `lib/**/*.dart` file. Read before adding widgets, repos, or tools.
3. **Recent implementation reality** when older docs disagree — e.g. live paths are `lib/app/` (not `lib/features/`); flow is Splash → **Genre** → Gallery → Drawing; settings use `SettingPanelScaffold`, `SettingsRepository` in `data/`, `SettingViewModel`, parent gate on genre hub.
4. **[`.cursor/rules/`](.cursor/rules/)** — Mandatory style and architecture (same family as Cursor agents). Includes `doc-tree.mdc` for keeping §3 updated.
5. **[`docs/`](docs/)** — Product intent: `PRD.md`, `TRD.md`, `UI-UX.md`, `Design.md`. [`Memory.md`](docs/Memory.md) for decisions; [`Rules.md`](docs/Rules.md) for discipline. Treat `README.md` as partially stale if it still says `features/`.

## Mandatory workflow

1. **Before** new UI, repository, or engine files: open **Architecture.md §3** and **§3.5 Reuse quick index**. Search for an existing class to extend or compose.
2. **Implement** following `.cursor/rules/` (simple `core/`, one public class per file, reuse `CircleButton`, `RoundedButton`, `AppTypography`).
3. **After** any add/move/rename/delete under `lib/`: update **Architecture.md §3.2** and bump **Last updated** in §3 — same task, same commit if the user commits.

## Composition and navigation

- **Entry:** [`lib/main.dart`](lib/main.dart) — Floor `kids_drawing.db`, `ArtworkCatalogSeeder`, `DeviceIdStore`, `MultiProvider`:
  - `SettingsRepository` + `SettingViewModel`
  - `CatalogRepository` + `DrawingViewModel`, `GalleryViewModel`
  - `GenreViewModel`
  - `AppWidget` → `SplashScreen`
- **User journey:** Splash (3s) → `GenreScreen` → `GalleryScreen` → `DrawingScreen` → optional `CompleteScreen`.
- **Settings:** Genre → parent gate (`ParentGate`) → modal `SettingDialog` (`app/setting/screen/setting.screen.dart`). Seven panels under `app/setting/panels/`; shared chrome `SettingPanelScaffold` (title + close fixed, body scrolls).

## Layer rules (short)

| Layer | May import | Must not |
| --- | --- | --- |
| `lib/app/` screens | `state/`, own widgets, `core/ui/`, `lib/types/` | `data/local` impls, repository impls |
| `lib/state/` | `foundation`, `dart:ui`, repository **interfaces**, `core/engine`, `core/tools`, `types/` | Feature widgets |
| `lib/core/` | `types/`, other `core/` | `app/`, `state/` |
| `lib/data/` | `types/`, local, dio (future) | Flutter UI, `state/`, `app/` |

Wire concrete repos and DB only in `main.dart` (no separate `app.dependencies.dart` unless it exists in the tree).

## Typography and shared UI

- Import [`app.typography.dart`](lib/core/ui/theme/app.typography.dart): `boldStyle`, `semiBoldStyle`, `numericStyle` for counters/volume/parent gate math.
- Round tappable icons: [`circle.button.dart`](lib/core/ui/widgets/circle.button.dart). Image tiles: [`rounded.button.dart`](lib/core/ui/widgets/rounded.button.dart).
- Responsive scale: `context.rs()` from [`responsive.dart`](lib/utils/responsive.dart).

## Task routing

| Task | Start here |
| --- | --- |
| Stroke / region / undo | `core/engine/`, `state/drawing/drawing.view-model.dart`, `workspace.canvas.dart` |
| New brush | `core/tools/drawing.tool.dart`, copy `pencil.drawing.tool.dart` or siblings |
| Artwork / catalog | `data/local/floor/`, `catalog.repository.*`, `json.artwork.loader.dart` |
| Settings UI | `app/setting/panels/`, `setting.panel.scaffold.dart`, `setting.card.dart` |
| Genre / gallery | `app/genre/`, `app/gallery/`, `state/genre/`, `state/gallery/` |

## Drawing product invariants

- Region strokes do not bleed outside the picked closed region.
- Outlines draw above paint.
- One completed stroke = one undo step.
- Store stroke points in **canvas** coordinates, not raw screen pixels.
- Finger-lift burst is ephemeral (not undo, not persisted).

## Git and commits

- Conventional commits when the user asks to commit.
- Do not commit unless explicitly requested.

## Non-goals for assistants

- Do not claim 60 FPS or latency targets without measurements.
- Do not add Material `Scaffold` / `AppBar` as primary chrome.
- Do not create duplicate button/palette widgets when §3.5 already lists a shared one.
- Do not hand-edit `app.database.g.dart` (Floor codegen).

## Pointers

- **Full file map:** [`docs/Architecture.md` §3](docs/Architecture.md#3-codebase-map-live-tree)
- **Human rules:** [`docs/Rules.md`](docs/Rules.md)
- **Decisions log:** [`docs/Memory.md`](docs/Memory.md)