# Admin dashboard, catalog schema and sync

How artwork, genres and their voices get from an admin dashboard into a child's
phone — the database, the storage layout, the file-naming rule both sides must
agree on, and what the app does with all of it.

Two sections at the end list the sounds that **never** come from the dashboard,
because they ship inside the app.

---

## 1. How the two halves fit

The app always reads its **local Floor database**. Once a day it pulls what has
changed from Supabase into that same database. The screen never waits for the
network, and the app behaves identically with no network at all.

| Situation | What happens |
| --- | --- |
| First launch, online | The catalog is pulled from Supabase and stored locally — rows *and* audio. The bundled Dart seeds are never installed. |
| First launch, offline | The bundled seeds install so the app works. On the first successful sync, remote rows take over, matched by `slug`. |
| Every later launch | The local database, plus one background sync a day. |

Downloaded audio is **permanent**, not a cache. Once a clip is on the device it
stays there, so a child who has been online once is never silent again.

The app never calls a speech API. All voice audio is produced outside the app
and either ships with it or is downloaded as a file.

---

## 2. The database — four tables

Three ideas carry the design:

1. **Language-neutral data and localized data never share a table.** `genres`
   and `artworks` hold slugs, media, ordering, flags and the template. Nothing
   a human reads or hears lives there.
2. **One `translations` table for every localized value — text and audio
   together.** One row is one thing a child hears: the words *and* the clip
   that speaks them. Adding Arabic adds rows. Adding 25 more languages adds
   rows. No migration, no new table, no new dashboard screen.
3. **A `position` column makes pools free.** A genre can have three voice lines
   in English and two in Arabic; that is three rows and two rows.

The running copy of this schema lives in the dashboard repo as
`kid-drawing-app-admin/supabase/schema.sql` — one file, safe to re-run.

```sql
create table languages (
  code          text primary key,              -- 'en', 'ar'
  english_name  text not null,
  native_name   text not null,
  direction     text not null default 'ltr'
                check (direction in ('ltr','rtl')),
  is_active     boolean not null default false,
  sort_order    int not null default 0,
  updated_at    timestamptz not null default now()
);

create table genres (
  id                  uuid primary key default gen_random_uuid(),
  slug                text not null unique,     -- matches GenreModel.id
  image_path          text,                     -- genre-images/<file>
  title_fill_colors   jsonb not null default '[]'::jsonb,
  title_outline_color text,
  ambience            text[] not null default '{}',   -- bundled clip names
  sort_order          int not null default 0,
  status              text not null default 'draft'
                      check (status in ('draft','published','archived')),
  published_at        timestamptz,
  updated_at          timestamptz not null default now()
);

create table artworks (
  id                uuid primary key default gen_random_uuid(),
  slug              text not null unique,       -- matches ArtworkEntity.artworkKey
  genre_id          uuid not null references genres(id) on delete restrict,
  template_json     jsonb not null,
  template_version  int  not null default 1,
  min_app_version   text,
  is_premium        boolean not null default false,
  sort_order        int not null default 0,
  status            text not null default 'draft'
                    check (status in ('draft','published','archived')),
  published_at      timestamptz,
  updated_at        timestamptz not null default now()
);

create table translations (
  id                uuid primary key default gen_random_uuid(),
  genre_id          uuid references genres(id)   on delete cascade,
  artwork_id        uuid references artworks(id) on delete cascade,
  language_code     text not null references languages(code),
  field             text not null
                    check (field in ('title','voice')),
  position          smallint not null default 0,
  text              text not null,
  audio_path        text,                        -- voice/<lang>/<file>.mp3
  audio_bytes       int,
  audio_duration_ms int,
  audio_sha256      text,
  voice_id          text,                        -- which ElevenLabs voice spoke it
  model_id          text,
  generated_at      timestamptz,
  updated_at        timestamptz not null default now(),

  -- exactly one owner, with real foreign keys
  constraint one_owner check (num_nonnulls(genre_id, artwork_id) = 1)
);

create table app_locals (
  key            text not null,
  language_code  text not null references languages(code),
  value          text not null,
  updated_at     timestamptz not null default now(),
  primary key (key, language_code)
);

create unique index translations_genre_key
  on translations (genre_id, language_code, field, position)
  where genre_id is not null;

create unique index translations_artwork_key
  on translations (artwork_id, language_code, field, position)
  where artwork_id is not null;

create index artworks_browse   on artworks (genre_id, status, sort_order);
create index translations_sync on translations (language_code, updated_at);
create index genres_sync       on genres (updated_at);
create index artworks_sync     on artworks (updated_at);
create index app_locals_sync   on app_locals (language_code, updated_at);

-- `default now()` only fires on insert, and the sync reads
-- `updated_at > last_sync`. Without this trigger on every table, an edit
-- after the first insert is invisible to every phone.
create or replace function set_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

create or replace trigger genres_touch before update on genres
  for each row execute function set_updated_at();
-- …and the same on languages, artworks and translations.
```

### Which fields exist per entity

| Owner | `field` | `position` | Audio | Used for |
| --- | --- | --- | --- | --- |
| genre | `title` | 0 | no | The title over the genre circle (`GenreModel.name`) |
| genre | `voice` | 0, 1, 2 … | yes | The pool spoken when the genre opens; one is picked at random |
| artwork | `title` | 0 | no | The gallery caption |
| artwork | `voice` | 0, 1, 2 … | yes | The line spoken when the artwork opens |

Both kinds of row use the same two field names, so there is one vocabulary for
genres and artwork alike. An artwork voice pool is just `position` 1 and 2; the
app picks at random and never repeats the previous pick.

### Why two nullable owner columns instead of `entity_type` + `entity_id`

The generic shape is the usual way to write a shared translations table, and it
throws away referential integrity: Postgres cannot foreign-key a polymorphic
id, so a deleted genre leaves its translations behind and a typo can point at
nothing. The exclusive arc above keeps the single table **and** real
`on delete cascade`. A third localized entity later is one more nullable
column and one more partial index.

### Why audio lives on the translation row

The app finds a clip from the line it speaks, not from an id. Text and audio
are one fact, so they are one row. `audio_sha256` is what lets a sync
re-download only the clips that actually changed, and verify what arrived.

### Three rules that are not obvious

1. **`slug` is immutable once published.** The app stores a child's strokes
   against `artworkKey`. Renaming a slug on the server silently orphans their
   colouring. Enforce it with a trigger, not with discipline:

   ```sql
   create function freeze_published_slug() returns trigger as $$
   begin
     if old.status <> 'draft' and new.slug <> old.slug then
       raise exception 'slug is immutable once published (%).', old.slug;
     end if;
     return new;
   end $$ language plpgsql;

   create trigger artworks_freeze_slug before update on artworks
     for each row execute function freeze_published_slug();
   create trigger genres_freeze_slug before update on genres
     for each row execute function freeze_published_slug();
   ```

2. **Archive, never delete.** A child may have coloured that artwork. Setting
   `status = 'archived'` hides it from the gallery and keeps every row intact.
   `on delete restrict` on `artworks.genre_id` is there so a genre cannot be
   deleted out from under its artwork by accident.

3. **People who edit the catalog are rows in `users`; children are not.** A
   Google sign-in creates `users(id, email, user_type)` with `user_type`
   defaulting to `'user'`, which grants nothing until an admin promotes it to
   `'admin'`. App accounts, if they ever exist, are rows in the same table.
   **No child content and no device identifiers ever reach the server** — the
   colouring stays on the phone, which is both the product decision and what
   keeps a children's app clear of COPPA / GDPR-K exposure.

`template_version` and `min_app_version` cost nothing now and prevent the one
failure a synced catalog cannot recover from: pushing content that an older,
already-installed app cannot render.

### Row-level security

Anonymous (the app) may `select` rows with `status = 'published'` and nothing
else. All writes belong to the admin role. There are no anonymous writes
anywhere, because there is no user data.

---

## 3. Storage and the clip filename rule

Two buckets, public read:

| Bucket | Holds |
| --- | --- |
| `voice/<lang>/` | Every voice clip, flat inside a language folder |
| `genre-images/` | The circle image for each genre |

A clip's filename is **not free-form**. It is a pure function of the line it
speaks, so the app can find a clip without an index, a manifest or a database
lookup. The rule lives in `VoiceClips.fileNameFor`
([`lib/core/audio/voice.clips.dart`](../lib/core/audio/voice.clips.dart)):

1. trim and lowercase the line;
2. replace every run of characters that are not `a–z0–9` with `_`;
3. strip leading and trailing `_`;
4. cut to 48 characters, then strip any trailing `_`;
5. append `_`, then the 32-bit FNV-1a hash of the trimmed lowercased line as
   8 hex digits, then `.mp3`.

The dashboard must reproduce it exactly. This implementation is verified
against all 106 names the app currently generates:

```js
export function voiceFileName(text) {
  const normalized = text.trim().toLowerCase();
  const slug = normalized
    .replace(/[^a-z0-9]+/g, '_')
    .replace(/^_+|_+$/g, '');
  const short = slug.length <= 48
    ? slug
    : slug.slice(0, 48).replace(/_+$/, '');
  let hash = 0x811c9dc5;                       // FNV-1a, 32-bit
  for (const byte of new TextEncoder().encode(normalized)) {
    hash ^= byte;
    hash = Math.imul(hash, 0x01000193) >>> 0;
  }
  return `${short}_${hash.toString(16).padStart(8, '0')}.mp3`;
}
```

| Line | File |
| --- | --- |
| `yellow` | `yellow_05bf6449.mp3` |
| `A school bag, ready for books!` | `a_school_bag_ready_for_books_a7551a9f.mp3` |
| `School time! Let's color and learn!` | `school_time_let_s_color_and_learn_9f863dfd.mp3` |

The **language is the folder, never the name** — the same line in English and
Arabic produces the same filename, and only the folder keeps them apart.

Audio format: mono MP3, 22 kHz, ~32 kbps. A short line lands near 3 KB, so a
language's whole catalogue stays small enough to download over a phone
connection without anyone noticing.

---

## 4. The artwork template JSON

This is the format the app already reads
([`json.artwork.loader.dart`](../lib/data/local/artwork/json.artwork.loader.dart)).
Upload it as-is; the dashboard stores it in `artworks.template_json`.

```json
{
  "id": "school_bag",
  "name": "School Bag",
  "genre": "school",
  "viewBox": "0 0 512 512",
  "regions": [
    { "id": "left_strap", "path": "M155 145 C105 145 ... Z", "fill": "#FFFFFF" },
    { "id": "bag_body",   "path": "M145 145 Q145 125 ... Z", "fill": "#FFFFFF" },
    { "id": "zipper",     "path": "M170 305 L342 305", "fill": "none", "colorable": false }
  ],
  "lines": [],
  "outline": { "color": "#000000", "strokeWidth": 7 }
}
```

| Key | Required | What the app does with it |
| --- | --- | --- |
| `id` | yes | Internal id of the loaded artwork. Keep it equal to the slug. |
| `viewBox` | yes | `"0 0 W H"`. The app squares the artwork to `max(W, H)`. |
| `regions[]` | yes | Every colourable shape, **back to front** (see below). |
| `regions[].id` | yes | Unique within the artwork. |
| `regions[].path` | yes | SVG path data. |
| `regions[].fill` | yes | Start colour; `"none"` marks a detail line. |
| `regions[].colorable` | no | Defaults to `fill != "none"`. `false` = detail line. |
| `lines[]` | no | Extra detail strokes: `{ "path": "…" }`. Never colourable. |
| `outline.strokeWidth` | yes | Outline thickness; detail lines are drawn at 0.7×. |
| `name`, `genre`, `background`, `outline.color` | no | Read by people, ignored by the app — the row carries the real title and genre, and outlines are drawn in a fixed near-black. |

Four rules the dashboard must enforce, because each one fails silently:

1. **Region order is back to front.** Every region is cut out of the regions
   listed after it. A background shape listed last erases everything in front
   of it.
2. **`"fill": "none"` (or `"colorable": false`) is a detail line**, not a
   region a child can fill — a zipper, a whisker, a fold.
3. **Never use `background` as a region id.** The app builds its own
   `background` region from the page with every region cut out; that is the
   paper a child can also colour.
4. **Paths must parse** and ids must be unique. Validate on upload, not on the
   phone — a bad path means a region that cannot be coloured and nobody finds
   out until a child taps it.

The app bakes its own gallery thumbnail from the template
(`ArtworkThumbnailBaker`), so **no thumbnail upload is needed**.

---

## 5. Dashboard screens

### Languages

List, add, activate. Fields: `code`, English name, native name, direction.
Arabic is `rtl` — record it here; it is a fact about the language, not
something the app should guess.

Deactivating a language stops it being offered for new content; it does not
delete translations.

### Genres

List (ordered by `sort_order`), add, edit, reorder, archive. Per genre:

- slug (immutable once published), image, title colours, ambience clip names
  chosen from [the bundled list](#section-a--general-sounds-bundled-never-remote);
- **a tab per language**: the genre name, plus the voice-line pool — each line
  is a row with its text and its MP3.

### Artwork, inside a genre

List by genre, add, edit, publish, archive. Per artwork:

- slug (immutable once published), template JSON (validated on upload),
  premium flag, sort order;
- **a tab per language**: title, voice text, voice MP3.

### Publishing rules

- Nothing publishes without its **English** translation and English clip.
- Other languages are optional. A missing one is not an error — the app falls
  back (§6).
- **The dashboard generates the audio itself**, with ElevenLabs, from the text
  on the row: one request at `mp3_22050_32`, so it is encoded once at mono
  22 kHz / 32 kbps rather than re-compressed afterwards. It stores
  `audio_bytes`, `audio_duration_ms`, `audio_sha256`, and `voice_id` /
  `model_id` / `generated_at` so it is clear what produced a clip.
- The filename comes from the rule in §3, never from a human.
- Editing the text clears the audio, because the filename is derived from the
  words — otherwise the row would point at a clip of the old wording.

### App Locals (UI translations)

The `app_locals` table stores every user-facing string the app shows outside of
artwork and genre content. The app ships with English defaults hardcoded; the
dashboard provides translated values per language.

Machine-readable English defaults (all keys, sources, and gap flags):
[`docs/app-locals.en.json`](app-locals.en.json).

List all keys, grouped by screen. Each key has a value per active language.
Fields: `key` (read-only, defined by the app), `language_code`, `value`.

- **No audio** — these are button labels, headings and short copy, not voice
  lines.
- **Placeholders** use `{name}` syntax. The app calls
  `String.replaceAll('{name}', value)`. The dashboard should show the
  placeholder names next to the input so the translator knows which tokens
  to keep.
- A missing value is not an error — the app falls back to English, then to its
  hardcoded default.
- The key is immutable. Adding a new key means a new app release that knows
  about it; the dashboard does not invent keys.

**82 keys.** The complete list with English defaults:

| Key | English default |
| --- | --- |
| `connectivity.headline` | Connect to load artworks! |
| `connectivity.subtitle` | Turn on WiFi so we can download your coloring pages. |
| `connectivity.connect` | Let's Connect! |
| `connectivity.play_offline` | Play without internet |
| `connectivity.loading` | Loading artworks… |
| `genre.try_free` | Try free for 7 days |
| `genre.bottom_left_placeholder` | Bottom left |
| `drawing.erase_no` | NO |
| `drawing.erase_yes` | YES |
| `drawing.brush_size` | Brush size |
| `drawing.share_text` | Check out my drawing! 🎨 |
| `drawing.saved` | Saved! |
| `drawing.keep` | Keep |
| `drawing.let_go` | Let go |
| `drawing.complete_date_pattern` | MMM d, y |
| `parent_gate.title` | Ask a Grown-Up |
| `settings.title` | Settings |
| `settings.little_artist` | Little Artist |
| `settings.music` | Music |
| `settings.sounds_voice` | Sounds & Voice |
| `settings.language` | Language |
| `settings.subscription` | Subscription |
| `settings.help` | Help |
| `settings.about` | About |
| `little_artist.title` | Little Artist |
| `little_artist.who` | Who's the little artist? |
| `little_artist.girl` | Girl |
| `little_artist.boy` | Boy |
| `little_artist.siblings` | Siblings |
| `little_artist.how_old` | How old is {pronoun}? |
| `little_artist.what_loves` | What does {pronoun} love? |
| `little_artist.tap_to_choose` | Tap to choose |
| `little_artist.selected_count` | {count} selected |
| `little_artist.continue` | CONTINUE |
| `little_artist.pronoun_she` | she |
| `little_artist.pronoun_he` | he |
| `little_artist.pronoun_they` | they |
| `little_artist.age_0_2` | 0–2 |
| `little_artist.age_3_4` | 3–4 |
| `little_artist.age_5_6` | 5–6 |
| `little_artist.age_7_8` | 7–8 |
| `little_artist.age_9_11` | 9–11 |
| `little_artist.age_12_plus` | 12+ |
| `interest.animals` | Animals |
| `interest.music` | Music |
| `interest.seasons` | Seasons |
| `interest.school` | School |
| `interest.transport` | Transport |
| `interest.princesses` | Princesses |
| `interest.fruit_garden` | Fruit Garden |
| `music.title` | Music |
| `music.toggle` | Music |
| `music.puppy_playtime` | Puppy Playtime |
| `music.sunshine_skip` | Sunshine Skip |
| `music.bubble_pop` | Bubble Pop Parade |
| `music.rainbow_carousel` | Rainbow Carousel |
| `music.confetti_party` | Confetti Party |
| `sounds_voice.title` | Sounds & Voice |
| `sounds_voice.voice` | Voice |
| `sounds_voice.sfx` | Sound Effects |
| `sounds_voice.vibrations` | Vibrations |
| `language.title` | Language |
| `language.english_fallback` | English |
| `language.narrator_learning` | The narrator is learning {language} |
| `language.learning_description` | What it says on every page is on its way. Keep coloring — it'll join in when ready. |
| `language.got_it` | Got it |
| `subscription.title` | Subscription |
| `subscription.restore` | Restore Purchases |
| `subscription.privacy` | Privacy Policy |
| `subscription.terms` | Terms of Use |
| `subscription.no_plan` | No plan yet |
| `subscription.try_free_long` | Try Free for 7 days |
| `subscription.try_free_short` | Try Free |
| `subscription.paywall_soon` | Paywall coming soon |
| `help.title` | Help |
| `help.placeholder` | Contact us / FAQ links (coming soon) |
| `about.title` | About |
| `about.app_name` | Kids Drawing |
| `about.version_loading` | Version … |
| `about.version_format` | Version {version} (Build {build}) |
| `about.description` | Designed with love for young creative minds. Unleash imagination with puppies, colors, and art! |
| `splash.title` | Splash |

---

## 6. The sync contract

**When.** On launch, in the background, if more than 24 hours have passed since
the last successful sync and the network is reachable. It never blocks a
screen, never shows a spinner, and does nothing at all when offline.

**What.** Rows where `updated_at > last_sync`, for the **device's language and
English only** — never all 26. Then, for every translation row whose
`audio_sha256` is new, the clip from `voice/<lang>/`.

A single RPC keeps it to one round trip:

```sql
create function catalog_delta(since timestamptz, langs text[])
returns jsonb language sql stable as $$
  select jsonb_build_object(
    'genres',       (select coalesce(jsonb_agg(g), '[]') from genres g
                      where g.updated_at > since),
    'artworks',     (select coalesce(jsonb_agg(a), '[]') from artworks a
                      where a.updated_at > since),
    'translations', (
      select coalesce(jsonb_agg(
        to_jsonb(t) || jsonb_build_object('genre_slug', g.slug, 'artwork_slug', a.slug)
      ), '[]'::jsonb)
      from translations t
      left join genres   g on g.id = t.genre_id
      left join artworks a on a.id = t.artwork_id
      where t.updated_at > since and t.language_code = any(langs)
    ),
    'app_locals',   (select coalesce(jsonb_agg(l), '[]') from app_locals l
                      where l.updated_at > since and l.language_code = any(langs)),
    'server_time',  now()
  );
$$;
```

Each translation carries its owner's **slug**. Without it, a line added to an
artwork that did not otherwise change arrives as a uuid the app cannot
resolve, because the parent row is not in that delta.

Archived rows come through the same delta — the app hides them; it does not
need a separate "deleted ids" list.

**Where files land.** `<application support>/voice/<lang>/<file>.mp3`, which is
exactly where `VoiceClips` already looks. Genre images go beside them under
`<application support>/catalog/`.

**Who owns what.**

| Owned by the remote | Owned by the device |
| --- | --- |
| slug, genre, template, premium, order, status | the child's strokes, the baked thumbnail, the revision counter |

A sync overwrites the first group and never touches the second. An archived
artwork leaves the gallery; if the child has strokes on it, the row stays in
the local database.

**The fallback chain, exactly.** For any line, in order:

1. the clip in the active language (bundled, then downloaded);
2. the device's own text-to-speech, reading **that language's text**;
3. English text, read by the device voice, if the language has no translation.

Never an English clip under a non-English UI — a sudden English voice is worse
than a synthetic one in the right language.

**Changing language in settings** asks for that language's rows and clips at
the next sync. Until they arrive the child hears step 2 or 3.

**Still to build in the app** (next round, not part of this document): Floor v3
with local `genres` and `translations` mirrors and `voiceFile` / `status` /
`sortOrder` / `remoteUpdatedAt` / `source` on artworks; genres moving out of
the hardcoded `GenreRepository`; and `ArtworkCatalogSeeder` becoming an offline
fallback instead of an unconditional seed.

---

## Section A — general sounds (bundled, never remote)

These ship inside the app. The dashboard never touches them.

| File | Length | Format | Plays when | Exists |
| --- | --- | --- | --- | --- |
| `assets/sounds/ui/tap_in.wav` | 0.17 s | mono 48 kHz PCM | Anything forward: a screen opens, something is picked | yes |
| `assets/sounds/ui/tap_out.wav` | 0.11 s | mono 48 kHz PCM | Anything leaving: back, close, cancel | yes |
| `assets/sounds/ui/tool_select.wav` | 0.50 s | mono 48 kHz PCM | A stick, colour or letter is picked | yes |
| `assets/sounds/ui/select_bell.mp3` | 1.06 s | mono 64 kbps | A genre is opened | yes |
| `assets/sounds/ui/burst_pop.mp3` | ≤0.5 s | mono ~64 kbps | The finger-lift burst after a stroke | **no** |
| `assets/sounds/music/puppy_playtime.mp3` | 38.7 s | mono 80 kbps | Background loop on splash and the genre hub | yes |
| `assets/sounds/music/{sunshine_skip,bubble_pop,rainbow_carousel,confetti_party}.mp3` | 30–60 s | mono 64–80 kbps | The other four tracks in the Music panel | **no** — each plays Puppy Playtime until its file lands |
| `assets/sounds/ambience/*.mp3` | ≤2 s each | mono ~64 kbps | Random genre background, 8–20 s apart | **no** — 24 clips |

The ambience clip names are shared between genres (`bird_chirp` serves animals,
seasons and fruit garden), and they are what a genre's `ambience` column picks
from. The full list is in [`Sound-Assets.md`](Sound-Assets.md).

---

## Section B — stationary tool sounds (bundled, never remote)

Also inside the app, also never from the dashboard. The drawing sounds
themselves are still to be produced.

### Stroke sounds

Named after `CategoryModel.drawSound`. The looping ones play for the length of
a stroke, so they must be seamless; the one-shots fire once per tap.

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
| `assets/sounds/draw/bucket.mp3` | no | color-balls — one tap fills a region |
| `assets/sounds/draw/stamp.mp3` | no | letters — one tap places a letter |

### Voice lines

Generated from `tool/voice_lines.json` by
`flutter test tool/voice_lines_export_test.dart`. Save each file in
`assets/voice/en/` — and in `assets/voice/<lang>/` for another language.

#### Tool category lines (3 each, picked at random)

| Key | Line | File |
| --- | --- | --- |
| `category.brush.0` | Paint brush! Swish swish! | `paint_brush_swish_swish_86be2841.mp3` |
| `category.brush.1` | Brushy brush! Let's paint! | `brushy_brush_let_s_paint_25f37c75.mp3` |
| `category.brush.2` | Dip, swish, beautiful! | `dip_swish_beautiful_cb753f82.mp3` |
| `category.color-balls.0` | Color balls! Tap and fill! | `color_balls_tap_and_fill_cb3708cd.mp3` |
| `category.color-balls.1` | Plop! Fill it up! | `plop_fill_it_up_28c006eb.mp3` |
| `category.color-balls.2` | Boop! All colored in! | `boop_all_colored_in_f1b3837f.mp3` |
| `category.crayon.0` | Crayons! Yay! | `crayons_yay_4a293569.mp3` |
| `category.crayon.1` | Crayon time! Color it up! | `crayon_time_color_it_up_856dd5a9.mp3` |
| `category.crayon.2` | Scribble it big! | `scribble_it_big_8e0a1df3.mp3` |
| `category.glitter.0` | Glitter! Sparkle sparkle! | `glitter_sparkle_sparkle_87ef0e14.mp3` |
| `category.glitter.1` | Oooh, shiny! | `oooh_shiny_ab16a476.mp3` |
| `category.glitter.2` | Let's make it twinkle! | `let_s_make_it_twinkle_64b60e2e.mp3` |
| `category.letters.0` | Letters! A, B, C! | `letters_a_b_c_77bc57ec.mp3` |
| `category.letters.1` | Let's stamp a letter! | `let_s_stamp_a_letter_cee9627b.mp3` |
| `category.letters.2` | Spell something fun! | `spell_something_fun_7b43f157.mp3` |
| `category.marker.0` | Markers! Big bold colors! | `markers_big_bold_colors_0a3056ab.mp3` |
| `category.marker.1` | Pop! Marker time! | `pop_marker_time_ef7f5ffb.mp3` |
| `category.marker.2` | Woohoo, let's color it in! | `woohoo_let_s_color_it_in_d41469a1.mp3` |
| `category.pencil.0` | Pencil time! Scribble scribble! | `pencil_time_scribble_scribble_489fd8af.mp3` |
| `category.pencil.1` | Pencil power! Ready, set, draw! | `pencil_power_ready_set_draw_663820b2.mp3` |
| `category.pencil.2` | Ooh, the pencil! Let's make lines! | `ooh_the_pencil_let_s_make_lines_eaacccd7.mp3` |
| `category.spray.0` | Spray can! Psssshh! | `spray_can_psssshh_7dfe9866.mp3` |
| `category.spray.1` | Shh shh! Spray it! | `shh_shh_spray_it_2a0e2d23.mp3` |
| `category.spray.2` | Whoosh! Color everywhere! | `whoosh_color_everywhere_7de5eaf8.mp3` |
| `category.tape.0` | Washi tape! Stick stick stick! | `washi_tape_stick_stick_stick_f7870195.mp3` |
| `category.tape.1` | Tape time! Pretty patterns! | `tape_time_pretty_patterns_026f9be9.mp3` |
| `category.tape.2` | Press it on! | `press_it_on_5f4f079d.mp3` |
| `category.watercolor.0` | Watercolors! Splish splash! | `watercolors_splish_splash_3bc4ce30.mp3` |
| `category.watercolor.1` | Ooh, soft and watery! | `ooh_soft_and_watery_5b3540c1.mp3` |
| `category.watercolor.2` | Let's make it dreamy! | `let_s_make_it_dreamy_80423e4a.mp3` |

#### Genre lines (also bundled, until a genre comes from the dashboard)

| Key | Line | File |
| --- | --- | --- |
| `genre.animals.0` | Animal friends! Let's color them together! | `animal_friends_let_s_color_them_together_10502346.mp3` |
| `genre.animals.1` | Hello animals! Who shall we color? | `hello_animals_who_shall_we_color_cbf1d68f.mp3` |
| `genre.coloring-arts.0` | Your coloring arts! Let's see what you made! | `your_coloring_arts_let_s_see_what_you_made_28d08ecb.mp3` |
| `genre.coloring-arts.1` | Look at all your pictures! | `look_at_all_your_pictures_5c34a3ed.mp3` |
| `genre.fruit-garden.0` | Yummy fruit garden! Let's color something sweet! | `yummy_fruit_garden_let_s_color_something_sweet_6ab26229.mp3` |
| `genre.fruit-garden.1` | So juicy! Pick a fruit! | `so_juicy_pick_a_fruit_f9178d39.mp3` |
| `genre.music.0` | Music time! Let's color the songs! | `music_time_let_s_color_the_songs_b8d02b7c.mp3` |
| `genre.music.1` | La la la! Let's make it colorful! | `la_la_la_let_s_make_it_colorful_61719196.mp3` |
| `genre.princes.0` | Princess time! Let's color the castle! | `princess_time_let_s_color_the_castle_0997ab12.mp3` |
| `genre.princes.1` | Sparkles and crowns! Let's go! | `sparkles_and_crowns_let_s_go_a3b33ef6.mp3` |
| `genre.school.0` | School time! Let's color and learn! | `school_time_let_s_color_and_learn_9f863dfd.mp3` |
| `genre.school.1` | Back to school! Grab your crayons! | `back_to_school_grab_your_crayons_5b56cedd.mp3` |
| `genre.seasons.0` | Sunshine, snow and rainbows! Let's color the seasons! | `sunshine_snow_and_rainbows_let_s_color_the_seaso_da710020.mp3` |
| `genre.seasons.1` | Every season is pretty! Pick one! | `every_season_is_pretty_pick_one_f5cb1724.mp3` |
| `genre.transport.0` | Cars, trains and planes! Let's color and go! | `cars_trains_and_planes_let_s_color_and_go_f3f17166.mp3` |
| `genre.transport.1` | Beep beep! Choose a ride! | `beep_beep_choose_a_ride_7d5005f9.mp3` |

#### Colour names — one clip each, shared by every category

13 colours, used by up to 8 categories apiece, so `yellow` is one file
and not eight.

| Line | File | Categories |
| --- | --- | --- |
| black | `black_568f4ba4.mp3` | 8 |
| blue | `blue_82fbf5cd.mp3` | 8 |
| brown | `brown_30be372f.mp3` | 8 |
| green | `green_011decbc.mp3` | 8 |
| orange | `orange_45b473eb.mp3` | 8 |
| pink | `pink_225e036d.mp3` | 8 |
| purple | `purple_9a6e02ff.mp3` | 8 |
| rainbow | `rainbow_2b6ce2a9.mp3` | 8 |
| red | `red_40f480dc.mp3` | 8 |
| sky blue | `sky_blue_84319b32.mp3` | 8 |
| violet | `violet_7b6d57f2.mp3` | 8 |
| white | `white_de020766.mp3` | 8 |
| yellow | `yellow_05bf6449.mp3` | 8 |

#### Colour-ball blends

| Line | File |
| --- | --- |
| Bright rainbow | `bright_rainbow_219e1b53.mp3` |
| Candy colors | `candy_colors_b1b2a87a.mp3` |
| Galaxy colors | `galaxy_colors_d975be63.mp3` |
| Ocean colors | `ocean_colors_2c4325e3.mp3` |
| Pastel rainbow | `pastel_rainbow_9890b776.mp3` |
| Pearl shine | `pearl_shine_7eb3c0e8.mp3` |
| Sunset colors | `sunset_colors_47daad51.mp3` |

#### Tape patterns

| Line | File |
| --- | --- |
| Bear tape | `bear_tape_f5c23659.mp3` |
| Bunny tape | `bunny_tape_e441296d.mp3` |
| Cat tape | `cat_tape_137597e5.mp3` |
| Chick tape | `chick_tape_c80514d1.mp3` |
| Dog tape | `dog_tape_64d93cdb.mp3` |
| Leopard tape | `leopard_tape_0b86e80e.mp3` |
| Panda tape | `panda_tape_ac64f871.mp3` |
| Paw tape | `paw_tape_450af9a5.mp3` |
| Penguin tape | `penguin_tape_bf34ee8d.mp3` |
| Rainbow tape | `rainbow_tape_22d305fb.mp3` |
| Zebra tape | `zebra_tape_4f2ffdbd.mp3` |

#### Letters

| Line | File |
| --- | --- |
| Letter A | `letter_a_c21ead52.mp3` |
| Letter B | `letter_b_c11eabbf.mp3` |
| Letter C | `letter_c_c01eaa2c.mp3` |
| Letter D | `letter_d_bf1ea899.mp3` |
| Letter E | `letter_e_be1ea706.mp3` |
| Letter F | `letter_f_bd1ea573.mp3` |
| Letter G | `letter_g_bc1ea3e0.mp3` |
| Letter H | `letter_h_cb1ebb7d.mp3` |
| Letter I | `letter_i_ca1eb9ea.mp3` |
| Letter J | `letter_j_c91eb857.mp3` |
| Letter K | `letter_k_c81eb6c4.mp3` |
| Letter L | `letter_l_c71eb531.mp3` |
| Letter M | `letter_m_c61eb39e.mp3` |
| Letter N | `letter_n_c51eb20b.mp3` |
| Letter O | `letter_o_c41eb078.mp3` |
| Letter P | `letter_p_d31ec815.mp3` |
| Letter Q | `letter_q_d21ec682.mp3` |
| Letter R | `letter_r_d11ec4ef.mp3` |
| Letter S | `letter_s_d01ec35c.mp3` |
| Letter T | `letter_t_cf1ec1c9.mp3` |
| Letter U | `letter_u_ce1ec036.mp3` |
| Letter V | `letter_v_cd1ebea3.mp3` |
| Letter W | `letter_w_cc1ebd10.mp3` |
| Letter X | `letter_x_db1ed4ad.mp3` |
| Letter Y | `letter_y_da1ed31a.mp3` |
| Letter Z | `letter_z_d91ed187.mp3` |

#### Seed artwork lines

These three ship with the app. Everything else comes from the dashboard.

| Key | Line | File |
| --- | --- | --- |
| `artwork.eraser` | An eraser, it rubs mistakes away. | `an_eraser_it_rubs_mistakes_away_98f7c0ec.mp3` |
| `artwork.pencil` | A pencil for drawing and writing. | `a_pencil_for_drawing_and_writing_611dafb1.mp3` |
| `artwork.school_bag` | A school bag, ready for books! | `a_school_bag_ready_for_books_a7551a9f.mp3` |

**106 clips in total**, about 1.8k characters — roughly 400 KB as mono
MP3. Re-run the export after writing any new line; it only ever adds.

---

## Checklists

### Add a language

1. `languages`: insert the code, names and direction. Leave `is_active` false
   until there is content.
2. Translate and record the genre names, genre voice lines, and every
   artwork's title and voice line.
3. Generate the audio, upload each clip to `voice/<code>/` under the name the
   rule in §3 produces.
4. Translate the 82 `app_locals` keys (see §5). Keep placeholders intact.
5. Set `is_active = true`.
6. A child who picks that language gets the new rows and clips at the next
   sync. Until then they hear the device voice reading translated text, and
   English text where a translation is missing.

### Add a genre

1. `genres`: slug, image, title colours, ambience clip names, sort order,
   `status = 'draft'`.
2. `translations`: the genre name per language, and 2–3 `voice` rows per
   language with their clips.
3. Add at least one published artwork — an empty genre is a dead end for a
   child.
4. `status = 'published'`; the dashboard stamps `published_at` on the first
   transition out of `draft`.
5. It appears on the genre hub after the next sync.

### Add an artwork

1. Prepare the template JSON and validate it against §4 — region order, detail
   lines, unique ids, no region called `background`.
2. `artworks`: slug, genre, template, premium flag, sort order,
   `status = 'draft'`.
3. `translations`: title and voice text per language; generate the clip for
   each voice line and upload it to `voice/<lang>/`.
4. Publish. English text and clip are required; other languages are optional.
5. After the next sync it appears in that genre's gallery, with its thumbnail
   baked on the device and its line spoken in the child's language.

### Retire an artwork or a genre

Set `status = 'archived'`. It leaves the gallery at the next sync. Rows and any
child's colouring stay where they are. **Never delete**, and never rename a
published slug — that is the one change the app cannot recover from.

### Translate UI strings (app locals)

1. The 82 keys are defined by the app — the dashboard does not create new ones.
   See the full list in §5 "App Locals (UI translations)" and
   [`app-locals.en.json`](app-locals.en.json).
2. For each active language, insert a row per key into `app_locals` with the
   translated `value`. English rows are optional (the app has hardcoded English
   defaults).
3. Placeholders like `{pronoun}`, `{count}`, `{language}`, `{version}`,
   `{build}` must appear verbatim in the translation — the app replaces them
   at runtime.
4. After the next sync the translated strings appear in the app. Missing keys
   fall back: current language → English → hardcoded default.

