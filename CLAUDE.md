# Alex's Beers

## Overview
- **Type:** Fun
- **Status:** Active
- **Tech:** Single-file HTML (saves to the browser, no internet needed)

## What This Is
A craft beer tasting journal for Greg's mate **Alex**. Log every beer he tries — name, brewery,
style, ABV, a 1–5 pint rating, tasting notes and a photo of the can/pint. Browser-first now,
with the plan to grow it into a phone app once the features are nailed. 🍺

The heart of it (per the council): a **personal beer diary** Alex actually uses — quick to log,
fun to flick through, and impossible to lose his history.

## How to use
Open `index.html` (▶ Launch) → **＋ Add a beer** → fill it in → **Save to shelf**.
- 🔍 Search and filter by style
- 🎲 **Surprise me** picks a beer for tonight
- ⬇ **Back up my beers** saves a file — tell Alex to do this now and then so nothing's ever lost

## Where it lives in Command Center
`projects/personal/alexs-beers/` → shows under the **Personal & Fun** group automatically.

## Roadmap (council plan)
- **Wave 1 — DONE:** add/edit/delete beers, photos (auto-resized), pint ratings, notes, search,
  style filter, stats bar, surprise-me, backup/restore.
- **Wave 1.1 — DONE:** "What I had with it" food/snack pairing per beer + its own 1–5 fork rating
  (🍴), shown on the card and included in search.
- **Wave 2 — DONE (badges):** 📖 Beer Passport with 14 stamps — milestones (First Pour → Beer
  Legend), style badges (Hop Head, Dark Arts, Sour Power, Crisp Boy), Style Hunter, Brewery Tour,
  Top Shelf, plus food ones (Snack Master, Perfect Pairing). Earned badges stamped; locked ones
  show a progress bar. (Spin-the-wheel already covered by "Surprise me" in Wave 1.)
- Custom hand-drawn SVG mascot (smiling pint) replaces the emoji.
- **Wave 3 — DONE (most):** 📍 "Where I drank it" per beer + 🗺️ stylised Canterbury **map** with
  pins that grow by beer count (offline, no map service); 📊 **My Taste** profile (favourite/best
  style, go-to brewery, top beer, avg strength, favourite snack, flavour-leaning bars); 📤 **share
  cards** — export a PNG tasting card for any beer, or an "Alex's Beers **Wrapped**" summary card.
- **Polish — DONE:** "Top snack" added to the stats bar; share-a-card to mates (the PNG export).
- **Phone app — DONE (first build):** wrapped as a real offline **Android app** with Capacitor.
  The single `index.html` is bundled inside the app (no hosting, no internet needed). Built and
  signed in the cloud via **GitHub Actions** (no Android Studio on Greg's PC). Repo:
  github.com/Haiku717/alexs-beers (private). First `app-debug.apk` built successfully and
  downloaded to `dist/`.

## How the Android build works
- `index.html` stays the single source of truth. `scripts/copy-web.mjs` copies it (+ icons +
  manifest) into `www/`, which Capacitor bundles. `sw.js` is left out of the app on purpose
  (files are already local); the service worker is skipped at runtime when `window.Capacitor` is
  present.
- To make a new version: edit `index.html`, then `git commit` + `git push`. GitHub Actions
  rebuilds the APK automatically. Download it from the run's Artifacts (or
  `gh run download <id> --dir dist`).
- gh CLI lives at `C:\Program Files\GitHub CLI\gh.exe` (not on PATH). Login = account "Haiku717".

## Next Steps
- [ ] Greg to sideload `dist/alexs-beers-apk/app-debug.apk` onto his phone, test, then send to Alex
- [ ] Swap Capacitor's default launcher icon for the custom pint icon (have `icon-512.png`)
- [ ] BEFORE Alex relies on it: set up a **stable signing key** (GitHub secret) so future updates
      install over the old app without uninstalling. Right now each cloud build uses a fresh debug
      key, so updating means uninstall+reinstall (use the in-app "Back up my beers" + restore to
      keep history safe across that).
- [ ] Possible extras: real GPS map (needs internet + a map service — trade-off vs offline),
      photo on the share card looks best with a landscape shot

## Session Log
### 2026-06-20
Convened the council (Pragmatist/Explorer/Critic/Mentor) → settled on "fun beer journal at heart,
durable storage, start small". Built Wave 1 as a single self-contained HTML app and filed it under
Personal & Fun in the Command Center. Nothing touches the Chill Air site.
