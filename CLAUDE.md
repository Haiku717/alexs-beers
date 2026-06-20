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
- **Phone app — DONE:** wrapped as a real offline **Android app** with Capacitor. The single
  `index.html` is bundled inside the app (no hosting, no internet needed). Built in the cloud via
  **GitHub Actions** (no Android Studio on Greg's PC). Repo: github.com/Haiku717/alexs-beers
  (private). Custom hand-drawn pint launcher icon (adaptive, all densities). Signed **release**
  APK (`app-release.apk`) with a permanent key, so updates install over the top WITHOUT wiping
  Alex's data. Latest build downloaded to `dist/alexs-beers-apk/app-release.apk`.

## How the Android build works
- `index.html` stays the single source of truth. `scripts/copy-web.mjs` copies it (+ icons +
  manifest) into `www/`, which Capacitor bundles. `sw.js` is left out of the app on purpose
  (files are already local); the service worker is skipped at runtime when `window.Capacitor` is
  present.
- To make a new version: bump `versionCode`/`versionName` in `android/app/build.gradle`, edit
  `index.html`, then `git commit` + `git push`. GitHub Actions rebuilds the signed APK
  automatically. Download it from the run's Artifacts (or `gh run download <id> --dir dist`).
- Icons: edit `make-app-assets.ps1` → run it → `npx @capacitor/assets generate --android`.
- gh CLI lives at `C:\Program Files\GitHub CLI\gh.exe` (not on PATH). Login = account "Haiku717".

## Signing key (important)
- The release APK is signed with a permanent key. The key + passwords live ONLY in GitHub
  **repo secrets** (`ANDROID_KEYSTORE_B64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`,
  `ANDROID_KEY_PASSWORD`) and a local copy at `android/keystore/release.jks` (gitignored, never
  committed). Same key every build = updates install over the top, data preserved.
- Don't lose the key: if both the local `release.jks` AND the secret were ever lost, a new key
  would force an uninstall/reinstall (data loss) on the next update. Keep a safe backup of
  `android/keystore/release.jks`.

## Next Steps
- [ ] Greg to sideload `dist/alexs-beers-apk/app-release.apk` onto his phone, test, then send to Alex
- [ ] Back up `android/keystore/release.jks` somewhere safe (e.g. password manager / Drive)
- [ ] Possible extras: real GPS map (needs internet + a map service — trade-off vs offline),
      photo on the share card looks best with a landscape shot

## Session Log
### 2026-06-20
Convened the council (Pragmatist/Explorer/Critic/Mentor) → settled on "fun beer journal at heart,
durable storage, start small". Built Wave 1 as a single self-contained HTML app and filed it under
Personal & Fun in the Command Center. Nothing touches the Chill Air site.
