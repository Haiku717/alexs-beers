// Copies the app's web files into ./www, which Capacitor bundles into the
// Android app. Keeps index.html in the project root as the single source of
// truth (Command Center still launches it directly) while the app build pulls
// from a clean folder. Cross-platform (runs on Windows + GitHub's Linux CI).
import { mkdirSync, copyFileSync, rmSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const www = join(root, 'www');

const FILES = [
  'index.html',
  'manifest.webmanifest',
  'icon-192.png',
  'icon-512.png'
];

rmSync(www, { recursive: true, force: true });
mkdirSync(www, { recursive: true });
for (const f of FILES) {
  copyFileSync(join(root, f), join(www, f));
}
console.log(`Copied ${FILES.length} files into www/`);
