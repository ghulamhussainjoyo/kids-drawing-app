# Sound assets

Every sound the app plays, where it comes from, and what still needs
authoring. Paths are relative to the repo root.

Code side: paths live as constants in
[`lib/core/audio/sound.assets.dart`](../lib/core/audio/sound.assets.dart).
Swapping any sound for the whole app is a one-line change there.

**A missing file is never an error.** `SfxPlayer` and `MusicPlayer` remember a
clip that fails to load and skip it silently, so the app runs — just quieter —
while the files below are still being made.

## In the app now

| File | Length | Format | Plays when |
| --- | --- | --- | --- |
| `assets/sounds/ui/tap_in.wav` | 0.17 s | mono 48 kHz PCM, 16 KB | Anything forward: a screen opens, something is picked |
| `assets/sounds/ui/tap_out.wav` | 0.11 s | mono 48 kHz PCM, 10 KB | Anything leaving: back, close, cancel |
| `assets/sounds/ui/tool_select.wav` | 0.50 s | mono 48 kHz PCM, 47 KB | A stick / colour / letter is picked |
| `assets/sounds/ui/select_bell.mp3` | 1.06 s | mono 64 kbps, 9 KB | A genre is opened on the hub |
| `assets/sounds/music/puppy_playtime.mp3` | 38.7 s | mono 80 kbps, 378 KB | Background loop on splash + genre hub |

The press pair and the select are WAV on purpose: uncompressed means no
decoder and no first-play lag, and 73 KB for the three costs nothing. Do not
re-encode them. The music was re-encoded from a 1.5 MB 320 kbps stereo master
to mono 80 kbps, because it is decoded into memory for a gapless loop.

Masters are kept outside the repo, in `~/Downloads/drawing-app/sounds/`.

## Still to author

Short effects: mono, ~48–64 kbps MP3 (or WAV if under ~20 KB), ≤15 KB each.

| File | Length | Plays when |
| --- | --- | --- |
| `assets/sounds/ui/burst_pop.mp3` | ≤0.5 s | The finger-lift burst, after a stroke |

Stroke sounds, named after `CategoryModel.drawSound`. The seven stick
categories loop for the length of the stroke, so they must be seamless;
`bucket` and `stamp` are one-shots.

| File | Loops | Category |
| --- | --- | --- |
| `assets/sounds/draw/pencil.mp3` | yes | pencil |
| `assets/sounds/draw/marker.mp3` | yes | marker |
| `assets/sounds/draw/glitter.mp3` | yes | glitter |
| `assets/sounds/draw/brush.mp3` | yes | brush |
| `assets/sounds/draw/crayon.mp3` | yes | crayon |
| `assets/sounds/draw/spray.mp3` | yes | spray |
| `assets/sounds/draw/watercolor.mp3` | yes | watercolor |
| `assets/sounds/draw/tape.mp3` | yes | tape |
| `assets/sounds/draw/bucket.mp3` | no | color-balls (one tap fills a region) |
| `assets/sounds/draw/stamp.mp3` | no | letters (one tap places a letter) |

Genre ambience: ≤2 s each, mono ~64 kbps, in `assets/sounds/ambience/`.
Clip names are shared between genres on purpose — `bird_chirp.mp3` is one
file used by animals, seasons and fruit garden. The pools are authored in
`GenreModel.ambience`, in
[`genre.repository.dart`](../lib/data/repositories/genre/genre.repository.dart).

| Genre | Clips |
| --- | --- |
| coloring-arts | `page_turn`, `chime`, `crayon_scribble` |
| school | `school_bell`, `kids_chatter`, `pencil_write` |
| animals | `bird_chirp`, `dog_bark`, `cat_meow`, `cow_moo` |
| music | `piano_note`, `guitar_strum`, `drum_tap`, `xylophone` |
| transport | `car_horn`, `train_whistle`, `plane_pass`, `bicycle_bell` |
| seasons | `bird_chirp`, `rain`, `wind`, `snow_crunch`, `leaves` |
| princes | `harp`, `sparkle`, `castle_fanfare` |
| fruit-garden | `bee_buzz`, `water_drop`, `bird_chirp`, `crunch` |

28 clips, 24 distinct files, roughly 300 KB in total — cheaper than one more
music loop, and it never gets repetitive.

Music tracks: the Music settings panel lists five, and only
`puppy_playtime` has a file. **A track with no file of its own plays the
`puppy_playtime` audio** (`MusicPlayer._fallbackTrackId`), so every row makes
a sound; drop `assets/sounds/music/<id>.mp3` in and that id takes over by
itself. **The ids are shared between
[`music_panel.dart`](../lib/app/setting/panels/music_panel.dart) and the
`setting_music_track` default in
[`settings.repository.impl.dart`](../lib/data/repositories/settings/settings.repository.impl.dart)
— change both together.**

`sunshine_skip`, `bubble_pop`, `rainbow_carousel`, `confetti_party`.

## Alternates on hand

Swapping is a one-line change in `sound.assets.dart`. Already in
`~/Downloads/drawing-app/sounds/claude/`, all with the same
`_press_in` / `_press_out` naming:

- `jungle_sounds/` — bamboo, frog, little bird (**in use**), jungle drum, little monkey
- `options/` — bubble pop, boing, xylophone, water drop, squeaky toy
- `pen_select_sounds/` — `A_swoop_sparkle`, `B_glitter_pop` (**in use**), `C_magic_run`, `D_slide_bounce`

## Voice

**The app never synthesises speech when it can avoid it — it plays a clip.**
[`VoiceClips`](../lib/core/audio/voice.clips.dart) looks for a line's
recording in two places, in order:

1. `assets/voice/<lang>/<slug>.mp3` — shipped with the app;
2. `<application support>/voice/<lang>/<slug>.mp3` — downloaded later,
   alongside a remote artwork. The language is the folder, so the same line in
   two languages cannot collide. See [`Admin-Dashboard.md`](Admin-Dashboard.md).

If neither has it, the device's own text-to-speech reads the text, so a line
is never mute — it just does not sound like the rest of the app.

### The filename rule — the contract with the admin dashboard

`VoiceClips.fileNameFor(text)` decides a clip's name, and it is a pure
function of the line. Lowercase it, collapse every run of non-letters to `_`,
trim leading and trailing `_`, cut to 48 characters, then append `_` and the
8-hex-digit FNV-1a hash of the trimmed, lowercased line, then `.mp3`:

```
"yellow"                         → yellow_05bf6449.mp3
"Ooh!"                           → ooh_49dd8c50.mp3
"A school bag, ready for books!" → a_school_bag_ready_for_books_a7551a9f.mp3
```

Anything that produces a clip — the admin dashboard, a hand-made recording —
must use that rule, and then no index, manifest or database column is needed to
find the file. The dashboard's copy of it, verified against all 106 names, is
in [`Admin-Dashboard.md`](Admin-Dashboard.md).

### Getting the clips

The lines are generated outside this repo — by whatever voice the user picks —
and dropped into `assets/voice/en/`. The repo's job is only to say **which
lines exist and what each file must be called**:

```sh
flutter test tool/voice_lines_export_test.dart        # → tool/voice_lines.json
```

That reads the real catalogs, so a new colour, genre or seed artwork can never
be missed, and it writes one entry per *distinct* line — which is why `yellow`
is a single clip shared by all seven stick categories. Today: **106 clips,
~1.8k characters.** Each entry carries the exact filename:

```json
{
  "text": "Glitter! Sparkle sparkle!",
  "file": "glitter_sparkle_sparkle_2b40e1f6.mp3",
  "keys": ["category.glitter.0"]
}
```

Generate the audio for `text`, save it as `file`, put it in
`assets/voice/en/`, and the app plays it. Nothing else is needed — no code
change, no manifest, no rebuild of anything but the app. Mono MP3 around
22 kHz / 32 kbps keeps ~110 lines near 400 KB.

A line that has no file simply falls back to the device voice, so clips can
arrive a few at a time.

### Where the text lives

On the thing being described, as before: `GenreModel.voice` and
`CategoryModel.voice` are now **pools** — `AppSound` picks one at random and
never repeats the previous pick, so a child who taps the pencil twenty times
hears three different lines. `StationaryModel.voice` defaults to the stick's
name — picking a colour says the colour, and nothing else — and an artwork row
carries its own `voice` column.

### Translating

Drop `assets/voice/<lang>.json` with the keys the app asks for and leave out
anything that should stay English:

```json
{
  "genre.school.0": "...",
  "category.marker.1": "...",
  "tool.pencil.yellow": "...",
  "artwork.school_bag": "..."
}
```

Keys are `genre.<id>.<n>`, `category.<name>.<n>`,
`tool.<category>.<name>` and `artwork.<artworkKey>`, where `<n>` is the
position in the pool. The file name is the settings language code lowercased
(`en_US` looks for `en_us.json`, then `en.json`). A translated line has no
clip, so the device voice reads it — render a `<lang>` folder the same way as
`en` to give that language real clips too.
