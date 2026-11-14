# Kids Drawing App — Delivery Stages

**Rule:** Finish one stage before starting the next.

## Intent

- **Stage 1** = local / development bootstrap only. Bundled JSON is seeded into Floor so we can build gallery, save, and reopen **without** Supabase. This is **not** the production catalog source.
- **Stage 2–3** = production path. IAP locks, then remote master + device sync.
- After Stage 3, new installs get catalog from **Supabase** (copy/sync per `deviceId`). Install seed is not the product catalog path; keep seed only as an optional debug flag if needed.

---

## Stage 1 — Seed on app install (local catalog) — DEV

**Goal:** Offline coloring works with real JSON artworks for local development; no Supabase, no IAP.

### Deliver
- Delete AppleAndBooks PoC
- JSON path parser → `ColoringArtwork`
- Floor: **one** `artworks` table (`genre` column)
- On first launch: seed catalog from bundled JSON into Floor
  (unified row: `templateJson`, empty `strokesJson`, `isPremium`, `deviceId`, …)
- Gallery loads from local DB by genre
- Open → color → debounce `strokesJson` → flush + thumbnail on back/pause
- Strokes in artwork space; `toolId` + `schemaVersion` on save (pencil only live)
- `isPremium` column present but **ignored** for gating (all openable)

### Out of stage 1
- IAP, paywall, Supabase, login

### Done when (dev milestone, not a store-release requirement)
- School bag / pencil / eraser (or more) seed → gallery → paint → leave → reopen same state offline

---

## Stage 2 — IAP (lock / unlock) — PRODUCTION

**Goal:** Premium artworks locked for free users; unlock via store. Still no Supabase required.

### Deliver
- Respect `isPremium` on catalog rows
- Gallery lock UI; block open if locked
- IAP purchase + restore (`in_app_purchase` / RevenueCat — pick one)
- Local `isPremiumUser` (or equivalent) entitlement
- Unlock rule: `!artwork.isPremium || isPremiumUser`

### Out of stage 2
- Server receipt validation (optional later), Supabase sync, Auth

### Done when
- Free user sees locks; after purchase/restore, premium artworks open; progress still local-only

---

## Stage 3 — Supabase save sync — PRODUCTION

**Goal:** Offline-first sync with remote master + per-device catalog. Production installs do **not** rely on bundled seed for catalog.

### Deliver
- Supabase master artworks (manual add)
- App: `SUPABASE_URL` + publishable key only (no DB password in client)
- On online: copy/merge master → device catalog (missing keys only; never wipe strokes)
- Push dirty local rows (strokes + thumbs) to remote
- `deviceId` ownership; nullable `userId` for future login
- Keep Floor as UI source of truth

### Out of stage 3
- Full Auth UI / account merge polish (column ready only), full brush engines

### Done when
- New install online gets catalog from remote; coloring syncs across relaunch; offline still works from local

---

## Order

1 (dev) → 2 (prod) → 3 (prod).  
Do not start Stage 3 until Stage 1 gallery/save is solid. Stage 2 can use seeded `isPremium` flags without remote. Stage 3 replaces seed-as-source with Supabase master → device catalog.