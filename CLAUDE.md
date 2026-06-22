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

## iPhone version (PWA via GitHub Pages) — DONE
- Alex has an iPhone, so alongside the Android app we host the SAME `index.html` as an installable
  web app. Apple blocks easy sideloading (a real native iOS app needs a Mac + $99/yr Apple
  Developer account + TestFlight), so the "Add to Home Screen" PWA route is the sensible path.
- **The repo was made PUBLIC** (was private) so free GitHub Pages can serve it. Pages = main branch
  root. Live URL: **https://haiku717.github.io/alexs-beers/** . The signing key is NOT exposed
  (gitignored + in repo secrets only).
- Greg already confirmed the privacy point: ALL of Alex's data (beers, notes, photos) is stored in
  the phone's `localStorage` only (index.html ~L544–548). There are ZERO network calls / analytics /
  uploads in the app — Pages just serves the static file, it never receives any logged data. The
  only data that leaves the phone is what Alex deliberately exports (backup file / share card).
- The app was already PWA-ready: apple meta tags + `manifest.webmanifest` + relative-path service
  worker (`sw.js`), so it works fine on the `/alexs-beers/` sub-path and offline after first load.
- Install on iPhone: open the URL in **Safari** → Share → **Add to Home Screen** → Add (do it once
  with signal so it caches for offline). Updates are automatic — push to `index.html`, Pages
  redeploys, the network-first service worker pulls the new version next time it's online.

## Shared log between mates (Supabase) — DONE
- The app is no longer a solo on-device diary: it's a **shared beer log for the crew**, synced via a
  free **Supabase** database. Both the Android app and the iPhone PWA use the SAME `index.html`, so
  they share one shelf.
- **How it works:** localStorage is still the offline cache + instant render. On load (and on app
  focus / coming back online) it pulls the shared shelf and merges. Adds/edits/deletes push to the
  cloud immediately when online, or queue locally (`_dirty` flag / `ab-pending-deletes`) and sync
  later. Each beer has a uuid `id` (cloud primary key) + `addedBy`. Nothing is lost offline.
- **Identity:** first open shows a passcode gate (`GROUP_PASSCODE = beers2026`), then asks the
  user's name (stored in `localStorage` `ab-name`). No real auth. Every beer is stamped
  "added by [name]"; there's an Everyone/[person] filter + a shared/offline status chip (tap to
  change name).
- **Supabase config is in `index.html`** near the top of the `<script>`: `SUPABASE_URL`,
  `SUPABASE_KEY` (the `sb_publishable_...` key — public by design), `GROUP_PASSCODE`. Project ref:
  `ccfyjufocwkmlozgsjim`. Table `beers (id uuid pk, created_at, added_by text, data jsonb)` with RLS
  policies allowing anon select/insert/update/delete. The Supabase JS lib loads from jsDelivr CDN at
  runtime; offline it just works locally.
- **Service worker (`sw.js` v3):** now only caches same-origin app files. Cross-origin requests
  (Supabase API + the CDN lib) always hit the network, so the shared shelf is never stale.
- **Security note (told Greg):** the passcode is a friendly gate, not real security. The publishable
  key is in the public repo, so anyone who reads the source could reach the DB. Fine for "just beers".
  To tighten later: lock RLS down or move the key behind a serverless function.
- Verified live before shipping: Supabase read (200), insert (201), delete (204) all OK with the key.

## Signing key (important)
- The release APK is signed with a permanent key. The key + passwords live ONLY in GitHub
  **repo secrets** (`ANDROID_KEYSTORE_B64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`,
  `ANDROID_KEY_PASSWORD`) and a local copy at `android/keystore/release.jks` (gitignored, never
  committed). Same key every build = updates install over the top, data preserved.
- Don't lose the key: if both the local `release.jks` AND the secret were ever lost, a new key
  would force an uninstall/reinstall (data loss) on the next update. Keep a safe backup of
  `android/keystore/release.jks`.

## Next Steps
- [x] Greg sideloaded `app-release.apk`, tested, working well (2026-06-21)
- [ ] Send Alex the iPhone link: https://haiku717.github.io/alexs-beers/ → Safari → Share → Add to Home Screen. Passcode: beers2026
- [ ] Test the shared log: add a beer on one phone, confirm it shows on another (with "added by")
- [x] Grabbed the new signed APK (v1.1, shared-log) → `dist/alexs-beers-apk/app-release.apk` (2026-06-22)
- [ ] Back up `android/keystore/release.jks` somewhere safe (e.g. password manager / Drive)
- [ ] Possible extras: real GPS map (needs internet + a map service — trade-off vs offline),
      photo on the share card looks best with a landscape shot

## Session Log
### 2026-06-22
Wrap-up session. Confirmed the v1.1 (shared-log) Android build succeeded in GitHub Actions and
downloaded the signed `app-release.apk` to `dist/` (ready to send Alex / sideload). Committed the
project notes documenting the iPhone PWA + Supabase shared-log work. Remaining: send Alex the
iPhone link, test the shared sync across two phones, and back up the signing key.

### 2026-06-21
Tested + shipped the Android APK (working well). Added an **iPhone version** by hosting the same
`index.html` as an installable PWA on **GitHub Pages** (repo made public). Then the big one: turned
the app from a solo on-device diary into a **shared crew log** via **Supabase** — passcode gate
(`beers2026`) + "what's your name" on first open, every beer stamped "added by [name]", Everyone/
[person] filter, offline-safe sync. Service worker bumped to v3 (only caches app files so the shared
shelf is never stale). Verified the Supabase read/insert/delete live before shipping. Bumped Android
to v1.1 so it gets the shared log too. iPhone link live: https://haiku717.github.io/alexs-beers/

### 2026-06-20
Convened the council (Pragmatist/Explorer/Critic/Mentor) → settled on "fun beer journal at heart,
durable storage, start small". Built Wave 1 as a single self-contained HTML app and filed it under
Personal & Fun in the Command Center. Nothing touches the Chill Air site.
